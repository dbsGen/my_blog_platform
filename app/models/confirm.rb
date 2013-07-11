class Confirm
  include Mongoid::Document
  EXPIRE_TIME = 24*3600

  field :token, type: String
  field :expire, type: Time

  index :token => 1
  belongs_to :user

  def self.rand_token(user)
    token = UUIDTools::UUID.timestamp_create.to_s.gsub '-', ''
    c = self.new token: token, user: user, expire: Time.now + EXPIRE_TIME
    c.save
    c
  end

  def self.confirm_token(token)
    c = self.find_by token: token
    if c.nil?
      false
    else
      if c.expire < Time.now
        c.destroy
        false
      else
        c.user.confirm = true
        c.user.password = 'password'
        c.user.save!
        c.destroy
        true
      end
    end
  end
end