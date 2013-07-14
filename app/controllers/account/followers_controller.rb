class Account::FollowersController < ApplicationController
  before_filter :enter_page
  layout 'user_page'

  def index
    @title = '关系'
  end

  def following
    key = params[:key]
    per_page = params[:per_page] || 25
    c = key.nil? ? current_user.following : current_user.following.where(name: /#{key}/)
    @total_page = c.count / per_page
    @users = c.paginate sort: :register_time.asc,
                        page: params[:page] || 1,
                        per_page: per_page
    render layout: nil
  end

  def followers
    key = params[:key]
    per_page = params[:per_page] || 25
    c = key.nil? ? current_user.following : current_user.followers.where(name: /#{key}/)
    @total_page = c.count / per_page
    @users = c.paginate sort: :register_time.asc,
                        page: params[:page] || 1,
                        per_page: per_page
    render layout: nil
  end

  def enter_page
    @page_index = :relations
  end
end
