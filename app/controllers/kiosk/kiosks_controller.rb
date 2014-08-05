require 'httpclient'

class Kiosk::KiosksController < Kiosk::ApplicationController
  @@client = HTTPClient.new
  @@domain = "http://kiosk.centermanagerpro.com/230"
  user = "cloudKiosks"
  password = "MioEnergyBlackCherry"
  @@client.set_auth(@@domain, user, password)
  
  @@headers = {
    'Accept' => '*/*',
    'Origin' => 'http => //kiosk.centermanagerpro.com',
    'X-Requested-With' => 'XMLHttpRequest',
    'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
    'Referer' => 'http => //kiosk.centermanagerpro.com/230/',
    'Accept-Encoding' => 'gzip,deflate,sdch',
    'Accept-Language' => 'en-US,en;q=0.8',
    'Connection' => 'Keep-Alive'
  }
  
  attr_accessor :swipe
  attr_accessor :waiver
  attr_accessor :cardid
  attr_accessor :pic
  
  def index
    puts "CALLING INDEX"
    puts session[:swipe]
    @swipe = session[:swipe]
    @waiver = session[:waiver]
    @pic = session[:pic]
  end

  def signin
    puts "SIGNIN"    
  end

  def register
    puts "REGISTER"    
  end

  def waiver
    puts "WAIVER"    
  end

  def pic
    puts "PIC"    
  end

  def swipe
    swipe_data = { :swipe => params[:swipe] }
    domain = "#{@@domain}/ajax/validateswipe.php"
    validate_swipe = @@client.post domain, swipe_data
    puts validate_swipe.status
    response = JSON.parse validate_swipe.content
    puts response
    @swipe = true
    if not response["reg"]
      flash.alert = "Card not registered"      
      @swipe = false
    end    
    session[:swipe] = @swipe
    session[:cardid] = response[:cardid]
    redirect_to :action => :index
  end
end
