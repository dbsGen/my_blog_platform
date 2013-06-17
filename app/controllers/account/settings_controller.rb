class Account::SettingsController < ApplicationController
  layout 'user_page'
  before_filter :require_confirm

  def show
    @page_index = :settings
    @title = t 'settings'
    @user = current_user
    #没有用户的情况下必须先登录
    if @user.nil?
      require_login
    end
  end

  def third_party

  end

  def set_host_domain
    domain = current_user.host_domain
    subdomain = params[:subdomain]
    if domain.nil?
      domain = Domain.new(word: subdomain, host: true, user: current_user)
      domain.save!
    else
      domain.word = subdomain
      domain.save!
    end
  end
end
