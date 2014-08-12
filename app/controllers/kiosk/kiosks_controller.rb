require 'httpclient'

class Kiosk::KiosksController < Kiosk::ApplicationController
  @@client = HTTPClient.new
  @@domain = "http://kiosk.centermanagerpro.com/230"
  user = "cloudKiosks"
  password = "MioEnergyBlackCherry"
  @@client.set_auth(@@domain, user, password)
  
  def reset
    signedin = session[:signedin]
    reset_session
    if signedin
      flash.notice = "Signed in successfully"
    end
    redirect_to :action => :index
  end

  def index
    @swipe = session[:swipe]
    @waiver = session[:waiver]
    @pic = session[:pic]
    @cardid = session[:cardid]
  end

  def signin
    @account = Account.find_by_email(params[:email])
    puts @account.inspect
    if @account.nil?
      flash.notice = "Email not found"
      session[:waiver], session[:swipe] = false, true
    else 
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
      response = JSON.parse save_data.content
      puts response
      if response["success"]  
        flash.notice = "Signed in as #{@account.codename}"      
        session[:waiver], session[:swipe] = true, false
      else 
        flash.notice = "An error occured: #{response}"
      end

    end
    redirect_to :action => :index
  end

  def register
    fname, lname = params['first_name'].strip.capitalize, params['last_name'].strip.capitalize
    dob_m, dob_d, dob_y = params['birth'].split('/')
    customer_data = {
      :cardid => session[:cardid],
      :FirstName => fname,
      :LastName => lname,
      :phone => '',
      :phone2 => '',
      :areacode => '813',
      :Sex => params['sex'],
      :CodeName => params['codename'].upcase,
      :GroupType => '', 
      :email => params['email'],
      :dob_y => dob_y,
      :dob_m => dob_m,
      :dob_d => dob_d
    }
    puts customer_data
    domain = "#{@@domain}/ajax/savedata.php"
    save_data = @@client.post domain, customer_data
    response = JSON.parse save_data.content
    if response["success"]
      flash.notice = "Registered as #{customer_data[:CodeName]}"
      session[:waiver], session[:swipe] = true, false
    else 
      flash.notice = "An error occured: #{response}"      
    end
    redirect_to :action => :index
  end

  def waiver
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
      flash.notice = "Error uploading waiver"
      redirect_to :action => :index
    end
    redirect_to :action => :index
  end

  def pic
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
      session[:signedin] = true
      redirect_to :action => :reset
    else
      flash.notice = "Upload error. Please try again (RESPONSE: #{save_photo.repsonse})"
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
    if not response["valid"]
      flash.notice = "Card Read Error"
      swipe = false
    elsif not response["reg"]
      flash.notice = "Card not registered"      
      swipe = false
    end    
    session[:swipe] = swipe    
    session[:cardid] = response["cardid"]
    redirect_to :action => :index
  end
end
