PrinterStatus
=============

Display Printer Status (Sinatra app)  

- display residual ink quantity
- send residual ink quantity mail by scheduler

## Getting Started

1. Clone  
 `git clone git@github.com:thinkAmi/PrinterStatus.git`  

2. Edit `.env.example` file  
 Change printer and mail settings for your environment  

3. Rename file: `.env.example` to `.env`  

4. Bundler  
 `bundle install --path vendor/bundle`  

5. Run  
 `bundle exec app.rb`  

6. Access
 `http://localhost:9494`  
　

 Note:  

 - if you change default port 9494, edit `set :port, 9494` in `app.rb` file 
 - if you change mail schedule, edit `settings.scheduler.every` method in `app.rb` file



## Tested environment
 * Windows7 x64
 * Ruby 2.0.0p481
 * gem list
  - sinatra 1.4.5
  - sinatra-contrib 1.4.2
  - thin 1.6.2
  - snmp 1.1.1
  - activesupport 4.1.1
  - lazy_high_charts 1.5.2
  - rufus-scheduler 3.0.7
  - pony 1.8
  - dotenv 0.11.1


## License
MIT  