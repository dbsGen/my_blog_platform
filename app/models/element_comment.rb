class ElementComment
  include MongoMapper::Document

  # index
  key :element_id,  String
  key :content,     Hash
  key :created_at,  Time
  belongs_to :user

  def self.comment(params = {})

  end

end