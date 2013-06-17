class ArticleGroup
  include MongoMapper::Document

  key :name, String, required: true
  key :article_ids, Array
  many :articles, :in => :article_ids
end