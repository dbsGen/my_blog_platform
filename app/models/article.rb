class Article
  include Mongoid::Document
  class << self
    include WillPaginate::Mongoid::CriteriaMethods
  end

  #文章的属性
  field :title, type: String
  field :created_at,  type: Time
  field :edited_at, type: Time
  field :like_count, type: Integer,  default: 0
  #点击数
  field :check_count, type: Integer,  default: 0
  #热度分数
  field :score, type: Float,    default: 20
  field :public, type: Boolean,  default: false
  #搜索用关键字
  field :key_word, type: String

  # Indexes
  index 'title' => 1
  index 'score' => 1
  index 'key_word' => 1

  CHECK_CONF = 1
  LIKE_CONF = 10
  COMMENT_CONF = 10
  MINUS_CONF = 1.3

  #写文章的人
  belongs_to :creater, class_name: 'User', inverse_of: :articles
  #文章的元素
  has_many :elements, class_name: 'Element', inverse_of: :article
  #评论
  has_many :comments
  #标签
  has_and_belongs_to_many :tags
  # 文章组
  has_and_belongs_to_many :article_groups

  validates :title, :length => {:minimum => 1, message: '标题不能为空'}
  #validates :elements, :length => {:minimum => 1, message: '内容不能为空'}
  #validates :tags, length: {:minimum => 1, message: '每篇文章至少要有一个Tag'}

  before_destroy :clean_elements
  after_save :save_elements

  def edited_at
    if @edited_at.nil?
      self.created_at
    else
      @edited_at
    end
  end

  #更改前或删除前需要，删除所有的元素
  def clean_elements
    elements.each do |element|
      element.destroy
    end
  end

  def summary
    begin
      fe = elements.first
    rescue Exception => _
      return ''
    end
    if block_given?
      c = yield fe.content
    else
      c = fe.content
    end
    c
  end

  def check
    self.update_attributes! check_count: check_count || 0 + 1
  end

  def update_score(time = Time.now)
    s = like_count * LIKE_CONF + check_count * CHECK_CONF + comments.count * COMMENT_CONF + 20
    p = ((time - created_at) / 3600 + 1).to_i**MINUS_CONF
    self.update_attributes! score: s/p
  end

  def save_elements
    elements.each { |element| element.save }
  end

  def update_key_word
    key = ''
    tags.each do |tag|
      key << "#{tag.label},"
    end

    key << "#{creater.nickname},"
    key << title
    self.set :key_word, key
  end

  def in_group?(group)
    (attributes['article_group_ids'] || []).include? group._id
  end
end
