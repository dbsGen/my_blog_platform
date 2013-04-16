require 'zip/zip'

class Account::Admin::TemplatesController < ApplicationController
  layout 'user_page'
  before_filter :require_admin, :enter_page
  before_filter :find_template, :only => [:destroy]

  # 全部模板显示
  def index
    @title =  "#{t('admin.title')}>#{t('templates.label')}"
    per_page = params[:per_page] || 25
    @total_page = Template.all().count / per_page + 1
    @templates = Template.paginate(
        :order    => :name.asc,
        :per_page => per_page,
        :page     => params[:page],
    )

    respond_to do |format|
      format.js {render :template => 'account/admin/templates/search'}
      format.html
    end
  end

  def search
    @title =  "#{t('admin.title')}>#{t('templates.label')}"
    per_page = params[:per_page] || 25
    templates = Template.where :name => /#{params[:key]}/
    @total_page = templates.count / per_page + 1
    @templates = templates.paginate(
        :order    => :name.asc,
        :per_page => per_page,
        :page     => params[:page],
    )

    respond_to do |format|
      format.js
      format.html {render :template => 'account/admin/templates/index'}
    end
  end

  def approve
    approve = params[:approve]
    @template = Template.find_by_id params[:id]

    if approve == 'true'
    #  通过批准，释放zip文件部署到服务器
      Zip::ZipFile.open @template.zip_file, Zip::ZipFile::CREATE do |zip_file|
        zip_file.each do |entry|
          if entry.name.match(/^(skim|edit)\/view\//).nil?
          #  判断这些为静态文件
            file_path = "#{CONFIG['static_file_path']}/#{@template.name}-#{@template.version}/#{entry.name}"
          else
            file_path = "#{CONFIG['dynamic_file_path']}/#{@template.name}-#{@template.version}/#{entry.name}"
          end
          try_time = 0
          begin
            entry.extract(file_path) {true}
          rescue Errno::ENOENT => e
            unless e.message['No such file or directory'].nil?
              FileUtils.mkdir_p e.message[/\/.+$/]
              try_time += 1
              retry if try_time < 3
            end
          end
        end
      end
      @template.set(
          dynamic_path: "#{CONFIG['dynamic_file_path']}/#{@template.name}-#{@template.version}/",
          static_path: "#{CONFIG['static_file_path']}/#{@template.name}-#{@template.version}/",
          verify: true
      )
      @template.dynamic_path = "#{CONFIG['dynamic_file_path']}/#{@template.name}-#{@template.version}/"
      @template.static_path = "#{CONFIG['static_file_path']}/#{@template.name}-#{@template.version}/"
      @template.verify = true
    else
    #  下架,删除部署好的文件
      p @template.static_path
      FileUtils.rm_r @template.static_path
      FileUtils.rm_r @template.dynamic_path
      @template.set(
          verify: false
      )
      @template.verify = false
    end
  end

  def download
    id = params[:id]
    if id.nil?
      render_401
    else
      template = Template.find_by_id id
      send_file template.zip_file
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
    if @template.destroy
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
