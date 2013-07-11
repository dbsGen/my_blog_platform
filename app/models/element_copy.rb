class Element_copy
  attr_accessor :content, :quote_info, :creater
  def initialize(element)
    @content = element.content
    @quote_info = element.quote_info
    @creater = element.comment.creater unless element.comment.nil?
    @creater = element.article.creater unless element.article.nil?
  end
end