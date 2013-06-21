class Comment
  include MongoMapper::Document

  key :created_at,  Time
  #多少楼
  key :flood, Integer

  belongs_to :creater,  :class => User
  belongs_to :reply_to, :class => Comment
  belongs_to :article

  many :reply_by, :class => Comment, :foreign_key => :reply_to_id
  many :elements

  validates :elements, :length => {:minimum => 1}
  validates :elements, :creater, :flood, :presence => true

  def summary
    begin
      fe = elements.first
    rescue Exception => _
      return ''
    end
    begin
      json = JSON(fe.content)
      content = json['content']
    rescue StandardError => _
      content = fe.content
    end
    c = yield content
    c.length > 250 ? "#{c[0..245]}..." : c
  end

end
