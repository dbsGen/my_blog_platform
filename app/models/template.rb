class Template
  include MongoMapper::Document

  #作为模板的标识
  key :name,      String
  #是否通过审核,未通过审核的不能上架使用
  key :verify,    Boolean, :default => false
  #是否引用 如果是其中的@信息会被保存
  key :is_quote,  Boolean, :default => true

  #类型content or blog
  key :type,  String
  #描述文件内容
  key :description, Hash

  key :created_at, Time

  key :version, Float

  belongs_to :creater, :class => User

  validates :name, :presence => {with:true, message: '名称不存在'}

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
    templates = self.where name:name, verify:true
    templates.first :order => :version.desc
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
    verify ? (description['icon_path'] || CONFIG['default_temp_icon']) : CONFIG['default_temp_icon']
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
end
