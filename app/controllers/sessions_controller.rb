class SessionsController < ApplicationController
  before_filter :require_no_login, :except => [:destroy, :new]
  caches_page :new, expires_in: 1.day

  #login页面
  #创建一个session
  def new
    @title = '登陆'
    @session = Session.new
  end

  #REST的创建接口=>登录
  def create
    p "Get the create event, User #{params} want to login"
    user_name = params[:user_name]
    password = params[:user_password]

    user = User.find_user_with_login user_name, password
    if user.nil?
      #登录失败，帐号或密码错误
      redirect_to login_path(err: t('login_failed'))
    else
      #登录成功创建session
      session = Session.create_with_user(user, :ip_address => request.remote_ip)
      save_session session
      redirect = params[:redirect]
      if redirect.nil? or redirect.size == 0
        redirect_back_or_default root_url
      else
        redirect_to redirect
      end
    end
  end

  # 注销接口
  def destroy
    token = saved_session
    unless token.nil?
      session = Session.session_with_token(token)
      unless session.nil?
        ret = session.destroy
        p "Delete #{ret}"
        # 删除成功
      end
    end

    #失败的情况也能退出，只是session没删掉
    remove_session
    flash[:information] = t('logout_success')
    redirect_to request.referrer || root_url
  end
end
