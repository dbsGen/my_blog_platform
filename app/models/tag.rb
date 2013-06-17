require 'errors'

class Tag
  include MongoMapper::Document

  key :label, String, required: true
  key :created_at, Time
  key :index_score, Float, default: 10

  key :article_ids, Array

  many :articles, :in => :article_ids
  belongs_to :creater, class: User

  validates :label,
            length: {maximum: 10, message: '文本不能超过10个'},
            format: {with: /[^,]+/, message: '文本中不能有","'}

  after_create :set_time

  def set_time
    self.created_at = Time.now
  end

  def self.add_tag_on_article(tag_label, article, user)
    tag = find_or_create_by_label tag_label
    tag.creater = user
    tag.articles << article
    article.tags << tag
    unless tag.save and article.save
      raise SaveError.new(tag, article)
    end
    tag
  end

  def self.remove_tag_from_article(label, article)
    tag = find_by_label label
    tag.article_ids.delete_if{|a| a == article.id}
    article.tag_ids.delete_if{|t| t == tag.id}
    unless tag.save and article.save
      raise SaveError.new(tag, article)
    end
  end

  def update_score(time = Time.now)
    interval = (time - (created_at || time)) / 3600
    self.index_score = article_ids.count / (interval.to_i + 1)
  end
end