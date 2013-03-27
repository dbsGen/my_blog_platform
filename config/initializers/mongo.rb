#初始化MongoDB

#这里到时候换成正式的服务器
MongoMapper.connection = Mongo::Connection.new(CONFIG['db_address'], CONFIG['db_ip'])
MongoMapper.database = "#{CONFIG['title']}_#{Rails.env}"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end

#初始化系统默认的templates
data = YAML.load(File.open('config/initializers/templates.yml'))
templates = data['templates'] || []
templates.each do |template|
  name = template['name']
  t = Template.where(:name => name).last
  if t.nil?
    t = Template.new(template)
    t.save
  else
    t.set(template)
  end
end

