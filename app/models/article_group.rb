require 'errors'

class ArticleGroup
  include Mongoid::Document

  field :name, type: String
  has_and_belongs_to_many :articles

  index :name => 1

  def <<(article)
    if articles.include? article
      articles << article
      article.article_groups << self
      raise Errors::MessageError.new('文章已经在文章组中了。')
    end
    articles << article
    article.article_groups << self
  end

  def >>(article)
    unless articles.include? article
      articles.delete article
      article.article_groups.delete self
      raise Errors::MessageError.new('文章没在文章组中。')
    end
    articles.delete article
    article.article_groups.delete self
    article.save!
  end

  def self.recommend_group
    find_or_create_by(name: 'recommend')
  end
end