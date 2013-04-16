class Template
  include MongoMapper::Document

  #作为模板的标识
  key :name,      String
  #是否通过审核,未通过审核的不能上架使用
  key :verify,    Boolean, :default => false
  #是否引用 如果是其中的@信息会被保存
  key :is_quote,  Boolean, :default => true
  #压缩文件路径
  key :zip_file, String
  #静态文件路径
  key :static_path, String
  #动态文件路径
  key :dynamic_path, String
  #描述文件内容
  key :description, Hash

  key :created_at, Time

  key :version, Fixnum

  belongs_to :creater, :class => User

  validates :name, :creater, :presence => true

  def screen_name
    h = description['screen_name']
    n = h[I18n.default_locale]
    h.each_value do |value|
      n = value
      return
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
    templates = self.where name:name
    templates.first :order => :version.desc
  end

  def self.create_with_params(params)
    template = params['template']
    hash = {
        name: template['name'],
        version: template['version'],
        is_quote: template['is_quote'],
        description: template,
        created_at: Time.now
    }
    self.new hash
  end

  def icon_path
    icon_path = description['icon_path']
    icon_path = CONFIG['default_temp_icon'] if icon_path.nil? or !verify
    "#{CONFIG['pic_temp_site']}#{icon_path}"
  end
end
