# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class AccountsController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    @accounts = get_accounts(:page => params[:page], :per_page => params[:per_page])

    respond_with @accounts do |format|
      format.xls { render :layout => 'header' }
      format.csv { render :csv => @accounts }
    end
  end

  # GET /accounts/1
  # AJAX /accounts/1
  #----------------------------------------------------------------------------
  def show
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new
    @timeline = timeline(@account)
    respond_with(@account)
  end

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @account.attributes = {:user => current_user, :access => Setting.default_access, :assigned_to => nil}

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end
    respond_with(@account)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Account.my.find_by_id($1) || $1.to_i
    end
    respond_with(@account)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    
    respond_with(@account) do |format|
      if @account.save
        @account.add_comment_by_user(@comment_body, current_user)
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @accounts = get_accounts
        get_data_for_sidebar
      end
    end
  end
  
  # POST /accounts (many)
  #----------------------------------------------------------------------------
  def create_many
    
    file_data = params[:account][:customers]
    if file_data.respond_to?(:read)
      file_contents = file_data.read
    elsif file_data.respond_to?(:path)
      file_contents = File.read(file_data.path)
    else
      logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
    end
    UploadJob.new.async.perform(file_contents, params[:account][:category], current_user)
    # head = true
    # saved = 0
    # CSV.parse(file_contents) do |row|
    #   if head
    #     headers = row.map{ |x| x.downcase }
    #     head = false
    #   else
    #     next if row[0].nil? or row[1].nil? or row[5].nil? or row[3].nil?
    #     data[:name] = "#{row[0].strip.capitalize} #{row[1].strip.capitalize}"
    #     data[:email] = "#{row[4].strip.downcase}"  
    #     @comment_body = "Visited: #{row[5].strip}"
    #     data[:codename] = "#{row[6].strip.upcase}"
    #     data[:birth]= "#{row[3].strip}"
    #     data.delete_if { |k,v| k==:birth and v[0]=="0" }
    #     next if /[Tt]est/.match(data[:name])
    #     next if /[Tt]est/.match(data[:codename])
    #     next if data[:name].length > 63
        
    #     @account = Account.new()        
    #     @account.assign_attributes(data)
    #     if @account.save
    #       @account.add_comment_by_user(@comment_body, current_user)
    #       saved += 1          
    #     else 
    #       @account = Account.where(name: data[:name]).first
    #       if @account.nil?
    #         puts "Why was this not uploaded?"
    #       else
    #         @comments = Comment.find_all_by_commentable_id(@account.id)
    #         similar = false
    #         @comments.each  do |comment| 
    #           if comment[:comment] == @comment_body
    #             similar = true
    #           end
    #         end 
    #         puts "END"
    #         unless similar               
    #           @account.add_comment_by_user(@comment_body, current_user)
    #         end
    #       end
    #     end
    #   end
    # end        
    # flash.notice = "#{saved} accounts uploaded!"
    redirect_to action: 'index'
  end
  
  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@account) do |format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @account.access = params[:account][:access] if params[:account][:access]
      get_data_for_sidebar if @account.update_attributes(params[:account])
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @account.destroy
    respond_with(@account) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /accounts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # PUT /accounts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /accounts/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:accounts_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:accounts_sort_by]  = Account::sort_by_map[params[:sort_by]] if params[:sort_by]
    @accounts = get_accounts(:page => 1, :per_page => params[:per_page])
    set_options # Refresh options

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:accounts_filter] = params[:category]
    @accounts = get_accounts(:page => 1, :per_page => params[:per_page])

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

private

  #----------------------------------------------------------------------------
  alias :get_accounts :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @accounts = get_accounts
      get_data_for_sidebar
      if @accounts.empty?
        @accounts = get_accounts(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render default destroy.js
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @account.name)
      redirect_to accounts_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @account_category_total = Hash[
      Setting.account_category.map do |key|
        [ key, Account.my.where(:category => key.to_s).count ]
      end
    ]
    categorized = @account_category_total.values.sum
    @account_category_total[:all] = Account.my.count
    @account_category_total[:other] = @account_category_total[:all] - categorized
  end
end
