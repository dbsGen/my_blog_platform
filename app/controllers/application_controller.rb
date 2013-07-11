require 'errors'
#  所有controller的父类
#  @title String 页面的标题
#  @keys  Array  关键字
#  @summary String 内容简介

class ApplicationController < ActionController::Base
  rescue_from Errors::SaveError, Errors::MessageError, Mongoid::Errors::Validations, :with => :get_save_error
  before_filter :set_page_info, :page_code

  protect_from_forgery

  helper_method :login?, :current_user, :saved_session, :admin?, :user_with_domain

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

  #登录成功以后保存session
  def save_session(t_session)
    cookies[:login_token] = {value: t_session.login_token, domain: ".#{CONFIG.main_domain}"}
  end

  def remove_session
    cookies.delete :login_token, domain: CONFIG.main_domain
    session[:login_token] = nil
  end

  def saved_session
    cookies[:login_token]
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
      redirect_to login_url(err: t('must_login'))
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
      format.html{render_500}
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

    d = Domain.where(word: (subdomain.nil? ? domain : "#{subdomain}.#{domain}")).first
    d.nil? ? nil : d.user
  end

  protected
  def set_page_info
    @title = '我的博卡--MyBoKa'
  end

  def get_save_error(e)
    case
      when e.is_a?(Errors::SaveError)
        render_format(500, e.message)
      when e.is_a?(Mongoid::Errors::Validations)
        render_format(500, e.message.gsub('Validation failed: ', ''))
      when e.is_a?(Errors::MessageError)
        render_format 500, e.message
      else

    end
  end

  def page_code
    headers['Content-Type']  = 'text/html; charset=utf-8'
  end
end
