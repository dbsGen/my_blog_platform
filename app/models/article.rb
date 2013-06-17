class Article
  include MongoMapper::Document

  #文章的属性
  key :title,       String,   required:true
  key :created_at,  Time
  key :edited_at,   Time
  key :like_count,  Integer,  default: 0
  #点击数
  key :check_count, Integer,  default: 0
  key :score,       Float,    default: 20
  key :public,      Boolean,  default: false

  CHECK_CONF = 1
  LIKE_CONF = 10
  COMMENT_CONF = 10
  MINUS_CONF = 1.3

  #写文章的人
  belongs_to :creater, :class => User
  #文章的元素
  many :elements
  #评论
  many :comments
  #标签
  key :tag_ids, Array
  many :tags, :in => :tag_ids

  validates :title, :length => {:minimum => 1, message: '标题不能为空'}
  validates :elements, :length => {:minimum => 1, message: '内容不能为空'}
  validates :tags, length: {:minimum => 1, message: '每篇文章至少要有一个Tag'}

  before_destroy :clean_elements
  before_update :clean_elements

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
    self.set check_count: check_count || 0 + 1
  end

  def update_score(time = Time.now)
    s = like_count * LIKE_CONF + check_count * CHECK_CONF + comments.count * COMMENT_CONF + 20
    p = ((time - created_at) / 3600 + 1).to_i**MINUS_CONF
    self.set score: s/p
  end
end
