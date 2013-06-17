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
    @template = Template.find_by_id id
    return render_404 if @template.nil?
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    file = params[:file]
    check_template_path
    temp_path = "#{CONFIG['temp_zip_path']}/#{UUIDTools::UUID.timestamp_create.to_s.gsub('-','')}"
    File.open temp_path, 'wb' do |the_file|
      the_file.write file.read
    end

    zip_file = check_file(temp_path)
    if zip_file.nil?
      #没有通过检查
      FileUtils.rm_f temp_path
      return render_500
    end


    f = zip_file.read 'template.yml'
    template_info = YAML.load f
    name = template_info['template']['name']
    version = template_info['template']['version']
    if name.nil? or version.nil?
      zip_file.close
      FileUtils.rm_f temp_path
      return render_format 500, 'The template is upload, yet!'
    end

    test = Template.first name:name, version:version
    unless test.nil?
      zip_file.close
      FileUtils.rm_f temp_path
      return render_format 500, '这个名称和版本已经上传过了。'
    end

    zip_file.close
    zip_path = "#{CONFIG['zip_template_path']}/#{name}-#{version}.zip"
    template = Template.create_with_params template_info
    template.zip_file = zip_path
    template.creater = current_user
    template.save
    p template
    FileUtils.mv temp_path, zip_path
    render_format 200, 'success'
  end

  protected
  # 检测失败返回空,通过检测返回ZipFile
  # 得到的ZipFile需要记得close
  def check_template_path
    path = CONFIG['zip_template_path']
    FileUtils.mkdir_p path unless File.exist? path
    temp_path = CONFIG['temp_zip_path']
    FileUtils.mkdir_p temp_path unless File.exist? temp_path
  end

  def check_file(file)
    begin
      zip_file = Zip::ZipFile.open(file, Zip::ZipFile::CREATE)
      zip_file.get_entry('template.yml')
      has_edit_view = false
      zip_file.each do |entry|
        has_edit_view = true unless entry.name.match(/^edit\/view\/content[\w.]+/).nil?
      end
      unless has_edit_view
        logger.error 'Get a template which has no edit_view'
        zip_file.close
        return nil
      end
      has_skim_view = false
      zip_file.each do |entry|
        has_skim_view = true unless entry.name.match(/^skim\/view\/content[\w.]+/).nil?
      end
      unless has_skim_view
        logger.error 'Get a template which has no skim view'
        zip_file.close
        return nil
      end
    rescue Exception => e
      logger.error "We get the wrong file #{e}"
      zip_file.close unless zip_file.nil?
      return nil
    end
    zip_file
  end

  def enter_page
    @page_index = :templates
    @title = t 'templates.label'
  end
end
