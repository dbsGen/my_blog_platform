class Session
  include Mongoid::Document

  TIME_OF_YEAR = 365 * 24 * 60 * 60

  #登录token
  field :login_token, type: String
  #是否需要验证ip
  field :need_ip, type: Boolean,  :default => false
  #每个session有一个ip地址的验证
  field :ip_address, type: String
  field :create_at, type: Time
  #过期时间
  field :expired, type: Time

  #关联的user
  belongs_to :user, inverse_of: :sessions

  index 'login_token' => 1

  validates :login_token, presence: {with: true, message: 'Login token 必须存在。'}

  def self.create_with_user(user, options = {})
    if options.is_a? Hash
      ip_address = options[:ip_address]
      need_ip = options[:need_ip]
    elsif options.is_a? String
      ip_address = options
      need_ip = false
    end
    now = Time.now
    hash = {
        :login_token => UUIDTools::UUID.timestamp_create.to_s.gsub('-',''),
        :expired => now + 3 * TIME_OF_YEAR,
        :create_at => now,
        user: user
    }
    unless ip_address.nil?
      hash[:need_ip] = need_ip if need_ip
      hash[:ip_address] = ip_address
    end
    session = Session.new hash
    session.save!
    session
  end

  def self.check_session(session, ip_address)
    #如果过期
    if session.expired < Time.now
      Session.destroy session.id
      return false
    end
    #检查ip
    !session.need_ip or session.ip_address == ip_address
  end

  def check_session(session, ip_address)
    Session.check_session(session, ip_address)
  end

  def self.session_with_token(token, ip_address = nil)
    session = Session.where(:login_token => token).last
    unless session.nil?
      session = check_session(session, ip_address) ? session : nil
      #登录一下，记录下登录时间
      if !session.nil? and !session.user.nil?
        session.user.login_with_session session
      end
      session
    else
      nil
    end
  end


end
