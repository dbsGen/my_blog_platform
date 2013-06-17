class Domain
  include MongoMapper::Document
  key :word, String
  #是否是我们的主机域名
  key :host, Boolean, default: true

  belongs_to :user

  validates :word,
            length: {minimum: 2, message: '二级域名过短'},
            presence: {with: true, message: '请输入二级域名'},
            uniqueness: {with: true, message:'域名重复'}
end