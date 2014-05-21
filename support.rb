require 'lazy_high_charts'
# Sinatraの場合、以下のIncludeが必要
include LazyHighCharts::LayoutHelper

require 'snmp'
require 'pony'
require 'dotenv'


class Support

  OID_PREFIX = '1.3.6.1.2.1.43.'
  OID_MARKER_PROCESS_COLORANTS = "#{OID_PREFIX}10.2.1.6.1."
  OID_MARKER_SUPPLIES_DESCRIPTION = "#{OID_PREFIX}11.1.1.6.1."
  OID_MARKER_SUPPLIES_LEVEL = "#{OID_PREFIX}11.1.1.9.1."


  Dotenv.load

  def initialize
    @manager = SNMP::Manager.new(host: ENV['HOST_IPV4'], version: :SNMPv1, community: ENV['COMMUNITY'])
  end


  def create_highcharts
    # 搭載されているインクタンク数を取得
    ink_count = recieve_ink_count


    results = Array.new
    1.upto(ink_count) do |i|
      # 描画する highcharts のエリアの大きさなどはここの sytle で指定する
      results << LazyHighCharts::HighChart.new('column', style: 'height:400px; width: 200px;') do |f|
        tank_name = recieve_tank_name(i)
        rest_volumn = recieve_rest_volumn(i)

        f.options[:chart][:defaultSeriesType] = 'column'
        f.plot_options({ column: { stacking: 'percent'}})
        f.xAxis({ categories: [tank_name] })

        # グラフの幅はここの pointWidth で指定する
        f.series(name: '使用済', data: [100 - rest_volumn], pointWidth: 40, color: 'gray')
        f.series(name: 'インク残量', data: [rest_volumn], pointWidth: 40, color: to_color(tank_name))
      end
    end

    results
  end


  def recieve_ink_count
    # SNMP::Integerクラスが返ってくるので、扱いやすいFixnumにしておく
    recieve_varbind(OID_MARKER_PROCESS_COLORANTS).to_i
  end


  def recieve_tank_name(tank_no)
    # SNMP::OctetStringクラスが返ってくるので、扱いやすいStringにしておく
    recieve_varbind(OID_MARKER_SUPPLIES_DESCRIPTION, tank_no).to_s
  end


  def recieve_rest_volumn(tank_no)
    # SNMP::Integerクラスが返ってくるので、扱いやすいFixnumにしておく
    rest_volumn = recieve_varbind(OID_MARKER_SUPPLIES_LEVEL, tank_no).to_i
  end


  def recieve_varbind(mib_id, tail = 1)
    # 末尾は通常 "1" っぽい。
    # タンクの残量を出す場合は、タンクの番号(1始まり)を指定する
    response = @manager.get("#{mib_id}#{tail.to_s}")
    response.each_varbind {|vb| return vb.value }
  end


  def to_color(tank_name)
    case tank_name
    when /^Black/
      'black'
    
    when /^Magenta/
      'red'

    when /^Yellow/
      'yellow'

    when /^Cyan/
      'blue'

    else
      'green'
    end
  end


  def send_mail
    Pony.mail({
      from: ENV['MAIL_FROM'],
      to: ENV['MAIL_TO'],
      subject: 'インク残量レポート',
      body: create_report,
      charset: 'UTF-8', # 日本語を使うので、明示的に charset 指定
      via: :smtp,
      via_options: {
        address:              ENV['SMTP_ADDRESS'],
        port:                 ENV['SMTP_PORT'],
        enable_starttls_auto: true,
        user_name:            ENV['USER_NAME'],
        password:             ENV['PASSWORD'],
        authentication:       :plain,
        domain:               ENV['DOMAIN']
      }
    })

    p "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")} - send mail"
  end


  def create_report
    ink_count = recieve_ink_count

    <<-EOF.gsub /^\s+/, ""
      #{Time.now.strftime("%Y/%m/%d %H:%M:%S")} 時点の状態
      インクの本数： #{ink_count} 本
      インクの残量：
      #{create_rest_volumn_content(ink_count)}
    EOF
  end


  def create_rest_volumn_content(ink_count)
    result = ''
    1.upto(ink_count) do |i|
      tank_name = recieve_tank_name(i)
      rest_volumn = recieve_rest_volumn(i)
      result += "・#{add_space(tank_name)} - #{rest_volumn}/100\n"
    end

    result
  end


  def add_space(str)
    addition = 40 - str.length
    str << "\s" * addition
  end
end