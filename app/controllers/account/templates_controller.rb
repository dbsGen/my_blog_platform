class Account::TemplatesController < ApplicationController
  layout 'least'
  before_filter :require_login

  def index
    @templates = current_user.usable_templates_and_check
  end

  def show
    id = params[:id]
    @index = params[:index]
    @template = Template.find_by_id id
    return render_404 if @template.nil?
    respond_to do |format|
      format.js
      format.html
    end
  end
end
