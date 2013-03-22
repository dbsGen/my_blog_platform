class Template
  include MongoMapper::Document

  key :path, String
  belongs_to :creater

end
