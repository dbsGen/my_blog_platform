require 'digest'

class User
  include Mongoid::Document
  class << self
    include WillPaginate::Mongoid::CriteriaMethods
  end
  EXPIRE_TIME = 24 * 3600

  field :name, type: String
  field :nickname, type: String
  field :email, type: String
  field :password_encrypt, type: String
  field :password_plain, type: String
  field :summary, type: String
  field :last_login_time, type: Time
  field :register_time, type: Time
  field :resend_time, type: Time
  field :portrait_path, type: String, :default => '/default_portrait.png'
  field :privileges, type: Integer, :default => 0
  field :confirm, type: Boolean, default: false
  field :blog_settings, type: Hash, :default => {}

  index 'name' => 1
  index 'email' => 1

  has_one :confirm_item, class_name: 'Confirm'
  has_one :findback_item, class_name: 'Findback'
  has_one :using_template, class_name: 'Template'

  #关联的sessions
  #有多少个sessions就说明有多少个登录可以删除
  has_many :sessions, inverse_of: :user
  #关联的三方登录状态
  has_many :third_parties
  has_many :domains
  embeds_many :notices do
    def check_for_key(key)
      where(key: key).count > 0
    end
  end

  attr_accessor :password

  has_many :articles, inverse_of: :creater
  has_many :created_templates,  class_name: 'Template', inverse_of: :creater

  has_and_belongs_to_many :show_articles, class_name: 'Article'

  has_and_belongs_to_many :usable_templates, class_name: 'Template'

  has_and_belongs_to_many :followers, class_name: 'User'
  has_and_belongs_to_many :following, class_name: 'User'

  has_many :comments, class_name: 'Comment', inverse_of: :creater
  has_one :using_blog_template, class_name: 'Template'

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
      self.update_attributes! :password_encrypt => pwd
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
    user.save ? user : nil
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
    tp = self.third_parties.where(:type => type).first
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
    usable_templates.all.concat DEFAULT_TEMPLATES
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
    using_blog_template.nil? ? Template.last_with_name(CONFIG.default_templates.blog_template['first']) : using_blog_template
  end

  def comment_template
    usable_templates_and_check.first(type: 'comment')
  end

  def unread_notices_count
    notices.where(:readed => false).count
  end

  def self.user_with_name(email_or_name)
    u = self.where(name: email_or_name).first
    u = self.where(email: email_or_name).first if u.nil?
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
      self.set :resend_time, Time.now + 5 * 60
    end
  end

  def goto_findback(url)
    if resend_time.nil? or Time.now > resend_time
      #可以发送
      c = self.findback_item
      c = Findback.rand_token(self) if c.nil?
      Email.confirm(email, '找回密码', url + c.token).deliver
      self.set :resend_time, Time.now + 5 * 60
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

  def templates_of_type(type)
    templates = usable_templates_and_check
    templates.reject{|t| t.type != type}
  end

  def follow(o_user)
    following << o_user
    o_user.followers << self
  end

  def unfollow(o_user)
    following.delete o_user
    o_user.followers.delete self
  end

  def follow?(o_user)
    following.include? o_user
  end
end
