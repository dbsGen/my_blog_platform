class Findback
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

  def self.confirm_token(token, delete = false)
    c = self.find_by_token token
    if c.nil?
      nil
    else
      if c.expire < Time.now
        c.destroy
        nil
      else
        u = c.user
        c.destroy if delete
        u
      end
    end
  end
end