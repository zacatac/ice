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
  
  def reset
    reset_session
    redirect_to :action => :index
  end

  def index
    puts "CALLING INDEX"
    @swipe = session[:swipe]
    @waiver = session[:waiver]
    @pic = session[:pic]
    @cardid = session[:cardid]
  end

  def signin
    puts "SIGNIN"    
    @account = Account.find_by_email(params[:email])
    puts @account.inspect
    session[:waiver], session[:swipe] = true, false
    flash.notice = "Signing in"
    if @account.nil?
      flash.alert = "Email not found"
      session[:waiver], session[:swipe] = false, true
    else 
      flash.notice = "Signed in as #{@account.codename}"
      fname, lname = @account.name.split(' ')
      dob_m, dob_d, dob_y = @account.birth.mon, @account.birth.mday, @account.birth.year 
      customer_data = {
        :cardid => session[:cardid],
        :FirstName => fname,
        :LastName => lname,
        :phone => '',
        :phone2 => '',
        :areacode => '813',
        :Sex => 'F',
        :CodeName => @account.codename,
        :GroupType => '', 
        :email => @account.email,
        :dob_y => dob_y,
        :dob_m => dob_m,
        :dob_d => dob_d
      }
      domain = "#{@@domain}/ajax/savedata.php"
      save_data = @@client.post domain, customer_data
      puts save_data.status
      response = JSON.parse save_data.content
      puts response
      if response[:success]
        session[:waiver], session[:swipe] = false, true
      end
    end
    redirect_to :action => :index
  end

  def register
    puts "REGISTER"    
  end

  def waiver
    puts "WAIVER"   
    waiver_data = {
      :cardid => session[:cardid],
      :custid => session[:cardid]      
    }
    domain = "#{@@domain}/ajax/savewaiver.php"
    save_waiver = @@client.post domain, waiver_data
    puts response
    if save_waiver.status == 200
      session[:swipe], session[:waiver], session[:pic] = false, false, true
    else
      flash.alert = "Error uploading waiver"
      redirect_to :action => :reset
    end
    redirect_to :action => :index
  end

  def pic
    puts "PIC" 
    photo_data = {
      :cardid => session[:cardid],
      :custid => session[:cardid],
      :data => params[:file]
    }
    domain = "#{@@domain}/ajax/uploadphoto.php"    
    save_photo = @@client.post domain, photo_data
    puts save_photo.content
    if save_photo.status == 200
      flash.notice = "Signed in successfully"
      redirect_to :action => :reset
    else
      flash.alert = "Upload error. Please try again"
      redirect_to :action => :index
    end
  end

  def swipe
    swipe_data = { :swipe => params[:swipe] }
    domain = "#{@@domain}/ajax/validateswipe.php"
    validate_swipe = @@client.post domain, swipe_data
    puts validate_swipe.status
    response = JSON.parse validate_swipe.content
    puts response
    swipe = true
    if not response["reg"]
      flash.alert = "Card not registered"      
      swipe = false
    end    
    session[:swipe] = swipe
    session[:cardid] = response["cardid"]
    redirect_to :action => :index
  end
end
