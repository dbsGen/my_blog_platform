class Account::SettingsController < ApplicationController
  layout 'user_page'

  def show
    @page_index = :settings
    @title = t 'settings'
    @user = current_user
    #没有传用户名的情况下必须先登录
    if @user.nil?
      require_login
    end
  end

  def third_party

  end

end
