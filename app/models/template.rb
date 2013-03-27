class Template
  include MongoMapper::Document

  key :name, String , :index => true
  #显示出来的名字
  key :screen_name, Hash
  key :file_path, String
  #只需要引用一次的代码
  key :edit_script_path, String
  key :skim_script_path, String
  key :icon_path, String

  key :create_at, Time

  key :version, String
  key :edited_at, Time

  belongs_to :creater

  validates :name, :presence => true

  def screen_name
    n = @screen_name[I18n.default_locale]
    @screen_name.each_value do |value|
      n = value
      return
    end if n.nil?
    n
  end

end
