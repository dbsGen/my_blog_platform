module UsersHelper
  def portrait_of_user(user)
    user.portrait_path.nil? ? '/default_portrait.png' : user.portrait_path
  rescue Exception=>e
    '/default_portrait.png'
  end
end
