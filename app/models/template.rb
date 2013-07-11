class Template
  include Mongoid::Document
  class << self
    include WillPaginate::Mongoid::CriteriaMethods
  end

  #作为模板的标识
  field :name, type: String
  #是否通过审核,未通过审核的不能上架使用
  field :verify, type: Boolean, :default => false
  #是否引用 如果是其中的@信息会被保存
  field :is_quote, type: Boolean, :default => true

  #类型content or blog
  field :type, type: String
  #描述文件内容
  field :description, type: Hash

  field :created_at, type: Time

  field :version, type: Float

  belongs_to :creater, class_name: 'User', inverse_of: :created_templates

  validates :name, :presence => {with:true, message: '名称不存在'}

  index 'name' => 1

  def screen_name
    h = description['screen_name']
    n = h[I18n.default_locale.to_s]
    h.each_value do |value|
      n = value
      break
    end if n.nil?
    n
  end

  def summary
    h = description['summary']
    s = h[I18n.default_locale]
    h.each_value do |value|
      s = value
      return
    end if s.nil?
    s
  end

  def self.last_with_name(name)
    self.where(name:name, verify:true).order_by(:version.desc).first
  end

  def self.create_with_params(params)
    hash = {
        name: params['name'],
        version: params['version'],
        is_quote: params['is_quote'],
        type: params['type'],
        description: params,
        created_at: Time.now
    }
    self.new hash
  end

  def icon_path
    verify ? (description['icon_path'] || "#{folder_name}/icon/icon.png") : CONFIG['default_temp_icon']
  end

  def paths(key = 'edit_path')
    if block_given?
      ps = description[key]
      js = []
      css = []
      ps.each do |v|
        p = Path.new v
        if p.type == 'css'
          css << p
        elsif p.type == 'js'
          js << p
        end
      end unless ps.nil?
      yield js, css
    else
      ps = description['edit_path']
      s = []
      ps.each do |v|
        p = Path.new v
        s << p
      end
      s
    end
  end

  def folder_name
    "#{name}-#{version}"
  end

  def settings
    raise 'This template is not a blog template.' if type != 'blog'
    Hashie::Mash.new(description).settings || []
  end
end
