#require 'rubygems'
require 'rufus/scheduler'
scheduler = Rufus::Scheduler.start_new

#没一小时 更新一次文章的热度
scheduler.every('1h') do
  now = Time.now
  Article.find_each do |article|
    article.update_score now
  end
  Tag.find_each do |tag|
    tag.update_score now
  end
end