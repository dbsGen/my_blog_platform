class Article
  include MongoMapper::Document

  #文章的属性
  key :title,       String, required:true
  key :created_at,  Time
  key :edited_at,   Time
  #写文章的人
  belongs_to :creater, :class => User
  #文章的元素
  many :elements

end
