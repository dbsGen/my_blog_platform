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
