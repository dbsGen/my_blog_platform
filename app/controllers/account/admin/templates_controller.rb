require 'zip/zip'

class Account::Admin::TemplatesController < ApplicationController
  layout 'user_page'
  before_filter :require_admin, :enter_page
  before_filter :find_template, :only => [:destroy]

  include Account::TemplatesHelper

  # 全部模板显示
  def index
    @title =  "#{t('admin.title')}>#{t('templates.label')}"
    per_page = params[:per_page] || 25
    @total_page = Template.all().count / per_page + 1
    @templates = Template.paginate(
        :sort     => :name.asc,
        :per_page => per_page,
        :page     => params[:page],
    )

    respond_to do |format|
      format.js {render :template => 'account/admin/templates/search'
      }
      format.html
    end
  end

  def search
    @title =  "#{t('admin.title')}>#{t('templates.label')}"
    per_page = params[:per_page] || 25
    templates = Template.where :name => /#{params[:key]}/
    @total_page = templates.count / per_page + 1
    @templates = templates.paginate(
        :sort     => :name.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    render layout: nil
  end

  def approve
    approve = params[:approve]
    @template = Template.find params[:id]

    if approve == 'true'
    #  通过批准，释放zip文件部署到服务器
      T_MANAGER.extend_static @template.name, @template.version
      logger.info "#### The static files path is #{"#{T_MANAGER.zip_path}/#{@template.name}-#{@template.version}.zip"} but got #{T_MANAGER.get @template.name, @template.version} The zip_path = #{T_MANAGER.zip_path}"
      @template.verify = true
      @template.save!
    else
    #  下架,删除部署好的文件
      T_MANAGER.remove_static @template.name, @template.version
      @template.verify = false
      @template.save!
    end
  end

  def download
    id = params[:id]
    if id.nil?
      render_401
    else
      template = Template.find_by_id id
      send_file T_MANAGER.get template.name, template.version
    end
  end

  # 默认模板 是用户一开始就拥有的
  def default
    data = YAML.load(File.open('config/initializers/templates.yml'))
    #这个templates是BSON型的
    @templates = data['templates']
  end

  def destroy
    @key = dom_id(@template)
    zip_file = "#{CONFIG['zip_template_path']}/#{@template.name}-#{@template.version}.zip"
    sp = assets_path(@template, '/')
    dp = TemplatePath.get @template
    if @template.destroy
      begin
        FileUtils.rm_f zip_file
        FileUtils.rm_f sp
        FileUtils.rm_f dp
      rescue Exception => e
        logger.warn "Can't remove the file #{e}"
      end
      respond_to do |format|
        format.js
      end
    else
      render_500
    end
  end

  protected
  def enter_page
    @page_index = :admin_templates
  end

  def find_template
    @template = Template.first(:id => params[:id])
    if @template.nil?
      render_404
    end
  end
end
