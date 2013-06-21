#初始化MongoDB

#这里到时候换成正式的服务器
MongoMapper.connection = Mongo::Connection.new(CONFIG['db_address'], CONFIG['db_ip'])
MongoMapper.database = "#{CONFIG['name']}_#{Rails.env}"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end
require "#{Rails.root}/db/indexes"

#Not need now
#初始化系统默认的templates
#data = YAML.load(File.open('config/initializers/templates.yml'))
#if data
#  templates = data['templates'] || []
#  templates.each do |template|
#    name = template['name']
#    t = Template.where(:name => name).last
#    if t.nil?
#      t = Template.new(template)
#      t.save
#    else
#      t.set(template)
#    end
#  end
#end

#默认一个评论使用的模板
COMMENT_TEMPLATE = Template.last_with_name(CONFIG['comment_template'])

T_MANAGER = TemplateManager::Manager.new path: CONFIG.zip_template_path,
                                         temp_path: CONFIG.temp_zip_path,
                                         static_path: CONFIG.static_file_path
tp = "#{Rails.root}/templates"
Dir.foreach tp do |file|
  unless ['.', '..'].include? file
    file_path = "#{tp}/#{file}"
    T_MANAGER.check file_path do |info, zip_file|
      test = Template.find_by_name_and_version(info.name, info.version.to_f)
      if test.nil?
        path = "#{T_MANAGER.zip_path}/#{info.name}-#{info.version}.zip"
        T_MANAGER.check_path path
        FileUtils.cp file_path, path
        TemplateManager::Decompression.actives zip_file, "#{CONFIG.dynamic_file_path}/#{info.name}-#{info.version}"
        t = Template.create_with_params info
        t.save!
      end
    end
  end
end