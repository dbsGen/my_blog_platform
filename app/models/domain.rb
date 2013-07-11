class Domain
  include Mongoid::Document
  field :word, type: String
  #是否是我们的主机域名
  field :host, type: Boolean, default: true

  belongs_to :user

  index 'word' => 1

  validates :word,
            length: {minimum: 2, message: '二级域名过短'},
            presence: {with: true, message: '请输入二级域名'},
            uniqueness: {with: true, message:'域名重复'}

end