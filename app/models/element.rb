class Element
  include MongoMapper::Document

  key :content, String
  #每个元素对应一篇文章
  belongs_to :article
  #每个元素有一个模板
  belongs_to :template

  validates :content, :length => {:minimum => 1}

end
