class UserCopy
  attr_accessor :name, :nickname, :email, :summary

  def initialize(user)
    self.name = user.name
    self.nickname = user.nickname
    self.email = user.email
    self.summary = user.summary
  end
end