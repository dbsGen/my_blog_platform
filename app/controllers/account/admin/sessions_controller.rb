class Account::Admin::SessionsController < ApplicationController
  before_filter :require_admin, :find_session
  def destroy
    @session_id = dom_id @session
    @session.destroy
    respond_to do |format|
      format.js
    end
  end

  protected

  def find_session
    @session = Session.first :id => params[:id]
    if @session.nil?
      return render :file => "public/404.html", :status => 404
    end
    @session
  end
end
