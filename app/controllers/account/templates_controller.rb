class Account::TemplatesController < ApplicationController
  layout 'least'
  before_filter :require_login

  def index
    @templates = current_user.usable_templates
    ts = CONFIG['default_templates']
    ts.each do |t|
      ft = @templates.first(:name => t)
      if ft.nil?
        @templates << Template.first(:name => t)
      end
    end
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
