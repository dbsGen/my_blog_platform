class Account::NoticesController < ApplicationController
  layout 'user_page'
  before_filter :require_login, :enter_page

  def index
    per_page = params[:per_page] || 25
    last = params[:last]
    notices = current_user.notices
    q = last.nil? ? notices : notices.where(:created_at.lte => params[:last])
    @notices = q.sort(:created_at.desc).limit(per_page)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def unread_count
    respond_to do |format|
      format.json {render :text => {count:current_user.unread_notices_count}.to_json}
    end
  end

  protected

  def enter_page
    @page_index = :notices
  end
end
