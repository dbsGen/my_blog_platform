require 'digest'

class User
  include MongoMapper::Document
  EXPIRE_TIME = 24 * 3600

  key :name,              String, :required => true, :unique => true
  key :nickname,          String
  key :email,             String, :required => true, :unique => true
  key :password_encrypt,  String
  key :password_plain,    String
  key :summary,           String
  key :last_login_time,   Time
  key :register_time,     Time
  key :resend_time,       Time
  key :portrait_path,     String, :default => '/default_portrait.png'
  key :privileges,        Integer, :default => 0
  key :confirm,           Boolean, default: false

  one :confirm_item,    class: Confirm
  one :findback_item,   class: Findback
  one :using_template,  class: Template

  #关联的sessions
  #有多少个sessions就说明有多少个登录可以删除
  many :sessions
  #关联的三方登录状态
  many :third_parties
  many :notices
  many :domains

  attr_accessor :password

  many :articles,           :class => Article,  :foreign_key => :creater_id
  many :show_articles,      :class => Article
  many :created_templates,  :class => Template, :foreign_key => :creater_id

  key  :usable_template_ids, Array
  many :usable_templates,   :class => Template, :in => :usable_template_ids

  many :comments,           :class => Comment,  :foreign_key => :creater_id
  belongs_to :using_blog_template, class: Template

  before_destroy :on_destroy

  validates :password_encrypt,
            presence: {with: true, message: '密码格式错误'},
            :length => {:minimum => 4, message: '密码格式错误'}
  validates :name, :email, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name,  :format => {:with => /\A\w+\z/, :message => '用户名只能是A-Z, a-z, _ 。'}, :length => {:in => 4..20}
  validates :email, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}
  validates :password, :length => {:minimum => 4}

  # 使用密码时候，如果有明文密码就用明文密码替换加密密码。方便修改密码
  def password_with_encrypt
    unless self.password_plain.nil?
      pwd = self.password_plain
      sha256 = Digest::SHA256.new
      5.times do
        pwd = Digest.hexencode sha256.digest(pwd)
      end
      self.set :password_encrypt => pwd
      self.unset :password_plain
    end
    self.password_encrypt
  end

  # 登录时使用检查是否能登录
  # @return user or nil
  def self.find_user_with_login(email_or_name, password)
    user = self.user_with_name(email_or_name)
    if user.nil?
      nil
    else
      user.password_with_encrypt == password ? user : nil
    end
  end

  # 使用session进行登录的时候调用
  def login_with_session(session)
    unless self.sessions.include? session
      self.sessions << session
    end
    self.last_login_time = Time.now
    self.save
  end

  # 注册用户，如果成功返回用户否则返回@nil
  def self.create_user(params)
    user = User.new :name => params[:user][:name],
                    :password_encrypt => params[:user][:password],
                    :email => params[:user][:email],
                    :password => 'this is password'
    user.register_time = Time.now
    yield(user) if block_given?
    user.save ? user: nil
  end

  def baidu_yun_info
    tp_info 'baidu_yun'
  end

  def youku_info
    tp_info 'youku'
  end

  def mingp_info
    tp_info 'mingp'
  end

  def tp_info(type)
    type = 'baidu_yun' if type == 'baidu'
    tp = self.third_parties.first(:type => type)
    return nil if tp.nil?
    if tp.expire?
      tp.destroy
      nil
    else
      tp
    end
  end

  def on_destroy
    sessions.each do |session|
      session.destroy
    end
    #暂时不需要
    #third_parties.each do |tp|
    #  tp.destroy
    #end
    notices.each do |notice|
      notice.destroy
    end

    domains.each do |domain|
      domain.destroy
    end
  end

  def usable_templates_and_check

    begin
      ts = CONFIG['default_templates']['content_templates']
    rescue Exception => _
      ts = []
    end

    ts.each do |t|
      ft = usable_templates.first(:name => t)
      if ft.nil?
        temp = Template.last_with_name(t)
        usable_templates << temp unless temp.nil?
      end
    end

    begin
      blog_temp = CONFIG['default_templates']['blog_template']['first']
    rescue Exception => _
      blog_temp = nil
    end

    t = usable_templates.first(:name => blog_temp)
    if t.nil?
      t = Template.last_with_name(blog_temp)
      usable_templates << t unless t.nil?
    end unless blog_temp.nil?

    usable_templates
  end

  def content_templates
    ts = []
    usable_templates_and_check.each do |t|
      ts << t if t.type == 'content' or t.type.nil?
      p t.type
    end
    ts
  end

  def blog_template
    using_blog_template.nil? ? usable_templates_and_check.first(type: 'blog') : using_blog_template
  end

  def comment_template
    usable_templates_and_check.first(type: 'comment')
  end

  def unread_notices_count
    notices.where(:readed => false).count
  end

  def self.user_with_name(email_or_name)
    u = self.find_by_name(email_or_name)
    u = self.find_by_email(email_or_name) if u.nil?
    return nil if u.nil?
    if !u.confirm and u.register_time + EXPIRE_TIME < Time.now
      u.destroy
      nil
    else
      u
    end
  end

  def goto_confirm(url)
    return 0 if confirm
    check_send do
      c = self.confirm_item
      c = Confirm.rand_token(self) if c.nil?
      Email.confirm(email, '邮箱验证', url + c.token).deliver
      self.set resend_time: Time.now + 5 * 60
    end
  end

  def goto_findback(url)
    if resend_time.nil? or Time.now > resend_time
      #可以发送
      c = self.findback_item
      c = Findback.rand_token(self) if c.nil?
      Email.confirm(email, '找回密码', url + c.token).deliver
      self.set resend_time: Time.now + 5 * 60
      0
    else
      resend_time - Time.now
    end
  end

  def check_send
    if resend_time.nil? or Time.now > resend_time
      yield if block_given?
      0
    else
      resend_time - Time.now
    end
  end

  def host_domain
    domains.each do |domain|
      return domain if domain.host
    end
    nil
  end

  def insert_article(article)
    articles << article
    show_articles << article
  end
end
