# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
BlogSystem::Application.initialize!
ActionMailer::Base.delivery_method = :smtp   # 以smtp邮件传送协议发送邮件
ActionMailer::Base.smtp_settings = {
    :address => 'smtp.ym.163.com',
    :port => 25,
    :domain => 'mingp.net',
    :authentication => :login,
    :user_name => 'no_reply@mingp.net',
    :password => '2327095'
}