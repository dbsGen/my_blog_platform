#初始化MongoDB

#这里到时候换成正式的服务器
MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "gen_blog_system_#{Rails.env}"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end