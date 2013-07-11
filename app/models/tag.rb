require 'errors'

class Tag
  include Mongoid::Document
  class << self
    include WillPaginate::Mongoid::CriteriaMethods
  end

  field :label, type: String
  field :created_at, type: Time
  field :index_score, type: Float, default: 10

  has_and_belongs_to_many :articles
  belongs_to :creater, class_name: 'User'

  index 'label' => 1

  validates :label,
            length: {maximum: 10, message: '文本不能超过10个'},
            format: {with: /[^,]+/, message: '文本中不能有","'}

  after_create :set_time

  def set_time
    self.created_at = Time.now
  end

  def self.add_tag_on_article(tag_label, article, user)
    raise Errors::MessageError.new('这个标签已经存在。') if article.tags.where(label: tag_label).count > 0
    tag = find_or_create_by label: tag_label
    tag.creater ||= user
    tag.articles << article
    article.tags << tag
    article.update_key_word
    tag
  end

  def self.remove_tag_from_article(label, article)
    tag = find_by label: label
    tag.articles.delete article
    article.tags.delete tag
    article.update_key_word
  end

  def update_score(time = Time.now)
    interval = (time - (created_at || time)) / 3600
    self.index_score = article_ids.count / (interval.to_i + 1)
  end
end