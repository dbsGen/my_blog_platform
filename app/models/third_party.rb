class ThirdParty
  include MongoMapper::Document

  #类型，用于站内识别
  key :type,    String
  #三方token,比如access_token
  key :token,   Hash
  #显示名字
  key :name,    String
  #备用
  key :others,  String
  #绑定的用户
  belongs_to :user

end
