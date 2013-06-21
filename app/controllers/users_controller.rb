require 'third_parties_api/mingp_api'

class UsersController < ApplicationController
  before_filter :require_no_login, :only => [:create, :new]
  before_filter :require_login, :only => [:update, :confirm]
  before_filter :require_no_confirm, only: [:confirm]
  before_filter :check_find_back, only: [:get_find_back]

  caches_page :find_back, :new, expires_in: 1.day
  #caches_action :confirm, :get_find_back
  #注册页面
  def new
    @user = User.new
  end

  #创建用户
  def create
    logger.info "Get the create event, User #{params} want to signup"
    #用户密码的加密方式是sha256 5次
    @user = User.create_user params do |user|
      begin
        #  开始获取用户数据
        body = MingpApi.user_info(user.email)
        json = JSON(body)
        user.nickname = json['user']['name']
        user.summary = json['user']['description']
      rescue Exception => e
        logger.warn("Can't get #{user.name}'s user info. #{e}")
      end
    end
    if @user
      #注册成功
      @user.goto_confirm(get_confirm_url(''))
      flash[:information] = {message: '注册成功，请前往邮箱认证以完成注册。'}
      session = Session.create_with_user @user, :ip_address => request.remote_ip
      save_session session
      redirect = params[:redirect]
      if redirect.nil? or redirect.size == 0
        redirect_back_or_default root_url
      else
        redirect_to redirect
      end
    else
      redirect_to signup_path(err: t('register_failed'))
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
    h = {}
    h_p = {}
    h[:summary] = h_p[:description] = summary unless summary.nil?
    nickname = params[:nickname]
    h[:nickname] = h_p[:name] = nickname unless nickname.nil?

    if h.size > 0
      MingpApi.edit_user_info(user.mingp_info.token, h_p)
      user.set h
    end

    render_format 200, t('modify_password.success')
  end

  def confirm
  end

  def send_confirm
    email = params[:email]
    u = User.find_by_email email
    return render_404 if u.nil?
    @expire = u.goto_confirm(get_confirm_url(''))
    if @expire > 0
      render_format 500, "#{(@expire / 60).to_i}分钟后才能再次发送。"
    else
      render_format 200, '发送成功,请前往邮箱查看。'
    end
  end

  def get_confirm
    success = Confirm.confirm_token(params[:token])
    if success
      flash[:information] = {message: '验证成功！'}
      redirect_to account_settings_path
    else
      flash[:information] = {message: '验证失败！',
                             type: 'error'}
      redirect_to confirm_path
    end
  end

  def find_back

  end

  def submit_find_back
    user = User.user_with_name(params[:user_name])
    return render template: 'users/no_user' if user.nil?
    @expire = user.goto_findback(get_find_back_url(''))
  end

  def get_find_back
  end

  def complete_find_back
    u = Findback.confirm_token(params[:token])
    @success = !u.nil?
    u.password_encrypt = params[:password]
    u.password = 'password'
    if @success
      if u.save
        #删除掉
        Findback.confirm_token(params[:token], true)
      else
        raise SaveError.new(u)
      end

    end
  end

  protected
  def check_find_back
    @user = Findback.confirm_token(params[:token])
    render_404 if @user.nil?
  end
end
