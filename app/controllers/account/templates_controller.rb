require 'zip/zip'

class Account::TemplatesController < ApplicationController
  layout 'user_page'
  before_filter :require_confirm, :enter_page

  def index
    @usable_templates = current_user.usable_templates_and_check
  end

  def show
    id = params[:id]
    @index = params[:index]
    @template = Template.find id
    return render_404 if @template.nil?
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    info = T_MANAGER << params[:file]

    test = Template.where(name:info.name, version:info.version).first
    return render_format 500, '这个名称和版本已经上传过了。' unless test.nil?

    template = Template.create_with_params info
    template.zip_file = zip_path
    template.creater = current_user
    return render_format 500, SaveError.message_in_objects(template) unless template.save
    render_format 200, 'success'
  rescue TemplateManager::Checker::CheckFailed => e
    render_format 500, e.message
  end

  protected

  def enter_page
    @page_index = :templates
    @title = t 'templates.label'
  end
end
