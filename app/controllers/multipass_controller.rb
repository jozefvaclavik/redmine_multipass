class MultipassController < ApplicationController
  unloadable
  skip_before_filter :user_setup, :check_if_login_required
  before_filter :multipass_enabled
  
  ##########################################
  #
  # Rescue From Decrypt Error
  #
  ##########################################
  rescue_from MultiPass::DecryptError do |exception|
    flash[:error] = l :multipass_error_decrypt
    redirect_to :controller => "account", :action => "login"
  end
  
  ##########################################
  #
  # Rescue From JSON Error
  #
  ##########################################
  rescue_from MultiPass::JSONError do |exception|
    flash[:error] = l :multipass_error_json
    redirect_to :controller => "account", :action => "login"
  end
  
  ##########################################
  #
  # Rescue From Expired Error
  #
  ##########################################
  rescue_from MultiPass::ExpiredError do |exception|
    flash[:error] = l :multipass_error_expired
    redirect_to :controller => "account", :action => "login"
  end

  ##########################################
  #
  # Index
  # -
  # sso => SSO String for further processing
  #
  ##########################################
  def index
    @sso = params[:sso]
    if @sso.to_s == ""
      # if SSO is empty, redirect to login with error msg
      flash[:error] = l :multipass_error_empty_sso
      redirect_to :controller => "account", :action => "login"
    else
      site_key = Setting.plugin_redmine_multipass['site_key']
      sso_api_key = Setting.plugin_redmine_multipass['sso_api_key']
      if site_key.to_s == "" or sso_api_key.to_s == ""
        # if settings arent done properly, redirect to login with error msg
        flash[:error] = l :multipass_error_missing_keys
        redirect_to :controller => "account", :action => "login"
      else
        @data = MultiPass.decode(site_key, sso_api_key, @sso)
        # decoding
        @usr = User.find(:all, :conditions => ["multipass_remote_uid = ?", @data[:remote_uid]]).first
        # searching for user according to remote_uid
        unless Setting.plugin_redmine_multipass['debug'] == "true"
          # unless debug mode isnt turned on, proceed.
          if @usr.nil?
            # user hasnt been found, register!
            if Setting.plugin_redmine_multipass['autoregistration'] == "true"
              # if autoregistration is turned on, proceed to register
              register(@data)
            end
          else
            # if user has been found, login
            login(@usr)
          end
        end
      end
    end
  end
  
  private
  
  ##########################################
  #
  # Login
  # -
  # user => User to be logged in
  #
  ##########################################
  def login(user)
    # maybe good idea would be to create cookie store for future login
    # TODO: consider cookies
    self.logged_user = user
    redirect_back_or_default :controller => 'my', :action => 'page'
  end
  
  ##########################################
  #
  # Register
  # -
  # hash => Decrypted hash with user info
  #
  ##########################################
  def register(hash)
    @user = User.new
    @user.login = hash[:login]    
    @user.firstname = hash[:first_name]
    @user.lastname = hash[:last_name]
    @user.mail = hash[:email]
    @user.multipass_remote_uid = @data[:remote_uid]
    @user.admin = false
    @user.language = Setting.default_language
    # login has to be unique
    # in case that it already exist, it has to be changed
    if !@user.valid? and !@user.errors[:login].empty?
      login = ""
      u = User.new
      u.valid?
      # combining login with _ and 5 randoom characters untill login is not valid
      while !u.errors[:login].nil? do
        login = "#{hash[:login]}_#{random_alphanumeric(5).downcase}" 
        u.login = login
        u.valid?
      end
      @user.login = login
    end
    # registering and activating user
    @user.register
    @user.activate
    if @user.save
      unless Setting.plugin_redmine_multipass['group_id'].to_i == 0
        # unless group isnt changed, add user to group
        group = Group.find(Setting.plugin_redmine_multipass['group_id'])
        @user.groups = [group]
      end
      self.logged_user = @user
      flash[:notice] = l :multipass_account_created
      redirect_to :controller => 'my', :action => 'account'
    else
      flash[:error] = "#{l :multipass_account_created_fail} (#{Setting.plugin_redmine_multipass['supportemail']})"
      redirect_to :controller => "account", :action => "login"
    end
  end
  

  ##########################################
  #
  # Multipass Enabled
  # Before filter
  #
  ##########################################
  def multipass_enabled
    unless Setting.plugin_redmine_multipass['enable'] == "true"
      flash[:error] = l :multipass_is_disabled
      redirect_to :controller => "account", :action => "login"
    end
  end
  
  ##########################################
  #
  # Randoom Alphanumeric
  # Method for randoom characters
  # -
  # size => size of requested string
  #
  ##########################################
  def random_alphanumeric(size = 16)
    s = ""
    size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
    s
  end
end
