class Comment
  include Mongoid::Document

  field :created_at, type: Time
  #多少楼
  field :flood, type: Integer

  belongs_to :creater,  class_name: 'User', inverse_of: :comments
  belongs_to :reply_to, class_name: 'Comment', inverse_of: :reply_by
  belongs_to :article

  has_many :reply_by, class_name: 'Comment', inverse_of: :reply_to
  has_many :elements

  validates :elements, :length => {:minimum => 1, message: '内容不能为空。'}
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
