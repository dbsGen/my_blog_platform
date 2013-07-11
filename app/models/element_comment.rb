class ElementComment
  include Mongoid::Document

  # index
  field :element_id, type: String
  field :content, type: Hash
  field :created_at, type: Time
  belongs_to :user

  def self.comment(params = {})

  end

end