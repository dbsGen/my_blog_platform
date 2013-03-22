class UsersController < ApplicationController
  before_filter :require_no_login, :only => [:create, :new]
  before_filter :require_login, :only => [:update]

  #注册页面
  def new
    @user = User.new
    store_location request.referrer if request.referrer.present?
  end

  #创建用户
  def create
    logger.info "Get the create event, User #{params} want to signup"
    #用户密码的加密方式是sha256 5次
    @user = User.create_user params
    if @user
      #注册成功
      session = Session.create_with_user @user, :ip_address => request.remote_ip
      save_session session
      redirect_back_or_default root_url
    else
      flash[:information] = {message: t('register_failed'),
                                type: 'error'}
      redirect_to signup_path
    end
  end

  def update
    p "Get the create event, User #{params} want to update"
    begin
      # 是否有传用户
      name = params[:name]
      email = params[:email]
      password = params[:password]
      user = User.find_user_with_login(name || email, password)
    rescue Exception => e
      user = nil
    end
    if user.nil?
      # 没有就使用当前登录用户
      user = current_user
    end
    if user.nil?
      return render_format 401, t('status.401')
    end
    new_password = params[:new_password]
    unless new_password.nil?
      old_password = params[:old_password]
      p "old is : #{old_password}, saved is : #{user.password_encrypt}"
      if user.password_encrypt == old_password
        user.set :password_encrypt => new_password
      else
        return render_format 401, t('modify_password.invalid')
      end
    end

    summary = params[:summary]
    unless summary.nil?
      user.set :summary => summary
    end

    render_format 200, t('modify_password.success')
  end
end
