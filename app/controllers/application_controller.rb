require 'errors'
#  所有controller的父类
#  @title String 页面的标题
#  @keys  Array  关键字
#  @summary String 内容简介

class ApplicationController < ActionController::Base
  rescue_from SaveError, :with => :get_save_error
  rescue_from MongoMapper::DocumentNotValid, :with => :get_save_error
  before_filter :set_page_info, :page_code

  protect_from_forgery

  helper_method :login?, :current_user, :saved_session, :remember_me?, :admin?, :user_with_domain

  def redis
    if @redis.nil?
      @redis = Redis.new
    end
    @redis
  end

  def store_location(path = nil)
    session[:return_to] = path || request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def set_remember_me(value)
    if value.nil?
      cookies[:remember_me] = 0
    elsif value.is_a?(String)
      cookies[:remember_me] = value == 'on' ? 1 : 0
    elsif value.is_a?(Boolean)
      cookies[:remember_me] = value ? 1 : 0
    elsif value.is_a?(Fixnum)
      cookies[:remember_me] = value == 0 ? 0 : 1
    end
  end

  # 是否勾选记住我
  def remember_me?
    r = cookies[:remember_me]
    r.nil? ? false : r.to_i == 1
  end

  #登录成功以后保存session
  def save_session(t_session)
    cookies[:login_token] = t_session.login_token if remember_me?
    session[:login_token] = t_session.login_token
  end

  def remove_session
    cookies[:login_token] = nil
    session[:login_token] = nil
  end

  def saved_session
    token = session[:login_token]
    if token.nil? #and remember_me?
      token = cookies[:login_token]
      session[:login_token] = token unless token.nil?
    end
    token
  end

  def user_from_saved
    Session.session_with_token saved_session, request.remote_ip
  end

  def current_user
    if @current_user.nil?
      session = user_from_saved
      @current_user = session.nil? ? nil : session.user
    end
    @current_user
  end

  def login?
    current_user != nil
  end

  def admin?
    login? ? current_user.privileges >= 10 : false
  end

  #检查登录

  def require_no_login
    if login?
      redirect_to root_url
    end
  end

  def require_login
    unless login?
      store_location
      flash[:information] = {message: t('must_login'),
                             type: 'error',
                             showCloseButton: true}
      redirect_to login_url
    end
  end

  def require_admin
    unless admin?
      render_401
    end
  end

  def require_confirm
    if login?
      redirect_to confirm_path unless current_user.confirm
    else
      store_location
      flash[:information] = {message: t('must_login'),
                             type: 'error',
                             showCloseButton: true}
      redirect_to login_url
    end
  end

  def require_no_confirm
    if login?
      if current_user.confirm
        redirect_to root_path
      end
    else
      store_location
      flash[:information] = {message: t('must_login'),
                             type: 'error',
                             showCloseButton: true}
      redirect_to login_url
    end
  end

  def render_format(status, msg = '')
    if msg.is_a?(String)
      p = {status:status, msg:msg}
    elsif msg.is_a?(Hash)
      p = {status:status}
      p.merge!(msg)
    end
    respond_to do |format|
      format.json{render :text => p.to_json, :status => status, :layout => false}
      format.xml{render :text => p.to_xml, :status => status, :layout => false}
      format.html{render :text => p.to_json, :status => status, :layout => false}
    end
  end

  def render_404
    render :file => "public/404.html", :status => 404, :layout => false
  end

  def render_401
    render :file => "public/401.html", :status => 401, :layout => false
  end

  def render_500
    render :file => "public/500.html", :status => 500, :layout => false
  end

  def user_with_domain
    domain = request.domain
    return nil if domain.nil?
    subdomain = nil
    if CONFIG['home_domain'].include? request.domain
      subdomain = request.subdomain
    end

    d = Domain.find_by_word subdomain.nil? ? domain : "#{subdomain}.#{domain}"
    d.nil? ? nil : d.user
  end

  protected
  def set_page_info
    @title = '我的博卡--MyBoKa'
  end

  def get_save_error(e)
    case
      when e.is_a?(SaveError)
        render_format(500, e.message)
      when e.is_a?(MongoMapper::DocumentNotValid)
        render_format(500, e.message)
      else

    end
  end

  def page_code
    headers['Content-Type']  = 'text/html; charset=utf-8'
  end
end
