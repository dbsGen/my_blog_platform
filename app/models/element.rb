class Element
  include MongoMapper::Document

  key :content,     String
  key :quote_info,  Hash
  #每个元素对应一篇文章
  belongs_to :article
  #或者对应一个评论
  belongs_to :comment
  #每个元素有一个模板
  belongs_to :template

  validates :content, :length => {:minimum => 1}

  #block 传出一个user
  def self.create_with_params(params)
    tn = params['template']
    c = params['content']
    arr = tn.split(',')
    name = arr.first
    version = arr.last.to_f
    template = Template.first(name: name, version: version)
    raise 'Temp not found' if template.nil?
    hash = {:content => c, :template => template}
    if template.is_quote
      qi = {}
      c.scan(ID_REGEXP).each do |quote|
        name = quote[1..-1]
        user = User.first(:name => name)
        unless user.nil?
          qi[name] = user.id
          yield user if block_given?
        end
      end
      hash[:quote_info] = qi
    end
    Element.new(hash)
  end

end
