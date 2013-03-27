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

  validates :title, :length => {:minimum => 1}
  validates :elements, :length => {:minimum => 1}

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

end
