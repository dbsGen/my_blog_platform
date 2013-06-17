module Account::Admin::ArticlesHelper
  def admin_name_tag(user)
    user.nil? ? '没有这个用户' : user.name
  end
end
