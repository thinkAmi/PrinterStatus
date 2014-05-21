require 'sinatra/base'
require 'sinatra/reloader'
require 'rufus/scheduler'
require './support.rb'



class PrinterStatus < Sinatra::Base
  configure do
    enable :logging
    set :environment, :production
    set :port, 9494
    
    set :scheduler, Rufus::Scheduler.new
  end

  configure :development do
    register Sinatra::Reloader
  end


  # インク残量お知らせメールをスケジューリング
  # settings.scheduler.cron '0 9 * * *' do # 毎日9時
  settings.scheduler.every '10m' do # 10分ごと
    Support.new.send_mail
  end


  get '/' do
    @charts = Support.new.create_highcharts

    erb :index
  end


  # エントリポイント
  run! if app_file == $0
end