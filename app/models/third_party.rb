class ThirdParty
  include Mongoid::Document

  #类型，用于站内识别
  field :type, type: String
  #三方token,比如access_token
  field :token, type: Hash
  #显示名字
  field :name, type: String
  #备用
  field :others, type: String
  #绑定的用户
  belongs_to :user

  index 'token' => 1

  def expire?
    case type
      when 'baidu_yun'
        expire = Time.at token['expires_at'].to_i
        Time.now > expire
      when 'mingp'
        false
      else
        false
    end
  end
end
