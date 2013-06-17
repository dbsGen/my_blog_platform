class Confirm
  include MongoMapper::Document
  EXPIRE_TIME = 24*3600

  key :token, String
  key :expire, Time
  belongs_to :user

  def self.rand_token(user)
    token = UUIDTools::UUID.timestamp_create.to_s.gsub '-', ''
    c = self.new token: token, user: user, expire: Time.now + EXPIRE_TIME
    c.save
    c
  end

  def self.confirm_token(token)
    c = self.find_by_token token
    if c.nil?
      false
    else
      if c.expire < Time.now
        c.destroy
        false
      else
        c.destroy
        c.user.set confirm: true
        true
      end
    end
  end
end