class Element_copy
  attr_accessor :content, :quote_info
  def initialize(element)
    @content = element.content
    @quote_info = element.quote_info
  end
end