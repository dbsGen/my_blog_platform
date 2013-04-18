require 'digest'

class User
  include MongoMapper::Document

  key :name,              String, :required => true, :unique => true
  key :email,             String, :required => true, :unique => true
  key :password_encrypt,  String
  key :password_plain,    String
  key :summary,           String
  key :last_login_time,   Time
  key :register_time,     Time
  key :portrait_path,     String, :default => '/default_portrait.png'
  key :privileges,        Integer, :default => 0

  #关联的sessions
  #有多少个sessions就说明有多少个登录可以删除
  many :sessions
  #关联的三方登录状态
  many :third_parties
  many :notices

  attr_accessor :password

  many :articles,           :class => Article,  :foreign_key => :creater_id
  many :created_templates,  :class => Template, :foreign_key => :creater_id
  many :usable_templates,   :class => Template

  many :comments,           :class => Comment,  :foreign_key => :creater_id

  before_destroy :on_destroy

  validates :name, :email, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name,  :format => {:with => /\A\w+\z/, :message => 'only A-Z, a-z, _ allowed'}, :length => {:in => 4..20}
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
    user = User.where(name:email_or_name).last
    if user.nil?
      user = User.where(email: email_or_name).last
      unless user.nil?
        p  "Stored password is #{user.password_with_encrypt} get password is #{password}"
        user.password_with_encrypt == password ? user : nil
      end
    else
      p "Stored password is #{user.password_with_encrypt} get password is #{password}"
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
    user.save ? user: nil
  end

  def baidu_yun_info
    self.third_parties.first(:type => 'baidu_yun')
  end

  def youku_info
    self.third_parties.first(:type => 'youku')
  end

  def tp_info(type)
    type = 'baidu_yun' if type == 'baidu'
    self.third_parties.first(:type => type)
  end

  def on_destroy
    sessions.each do |session|
      session.destroy
    end
    third_parties.each do |tp|
      tp.destroy
    end
    notices.each do |notice|
      notice.destroy
    end
  end

  def usable_templates_and_check
    ts = CONFIG['default_templates']
    ts.each do |t|
      ft = usable_templates.first(:name => t)
      if ft.nil?
        usable_templates << Template.last_with_name(t)
      end
    end
    usable_templates
  end

  def unread_notices_count
    notices.where(:readed => false).count
  end
end
