class MingpApi
  def self.user_info(email)
    #  开始获取用户数据
    client = HTTPClient.new
    response = client.get("#{MINGP_SITE}#{MINGP_P_USER_INFO}", email: email)
    response.body
  end

  def self.edit_user_info(token, options = {})
    client = HTTPClient.new
    options[:access_token] = token[:access_token]
    response = client.post("#{MINGP_SITE}#{MINGP_USER_INFO}", options)
    response.body
  end
end