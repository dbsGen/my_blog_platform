#初始化MongoDB
Mongoid.load!("#{Rails.root}/config/mongoid.yml")
Mongoid.logger = Rails.logger
#Moped.logger = Rails.logger
require 'will_paginate/mongoid'
#这里到时候换成正式的服务器

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
DEFAULT_TEMPLATES = Template.in(name: CONFIG.default_templates.content_templates.concat([CONFIG.default_templates.blog_template['first']]))

T_MANAGER = TemplateManager::Manager.new path: CONFIG.zip_template_path,
                                         temp_path: CONFIG.temp_zip_path,
                                         static_path: CONFIG.static_file_path
tp = "#{Rails.root}/templates"
Dir.foreach tp do |file|
  unless ['.', '..'].include? file
    file_path = "#{tp}/#{file}"
    T_MANAGER.check file_path do |info, zip_file|
      test = Template.where(name: info.name,version: info.version.to_f).first
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