class Account::Admin::ArticlesController < ApplicationController
  layout 'user_page'
  before_filter :require_admin ,:enter_page
  before_filter :find_article, :only => [:destroy, :show, :update]

  def search
    per_page = params[:per_page] || 25
    articles = Article.where :title => /#{params[:key]}/
    @articles = articles.paginate(
        :order    => :created_at.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    @total_page = articles.count / per_page + 1
    respond_to do |format|
      format.html {render :template => 'account/admin/articles/index'}
      format.js
    end
  end

  def index
    @title = t('articles.label')
    per_page = params[:per_page] || 25
    @total_page = Article.all().count / per_page.to_i + 1
    @articles = Article.paginate(
        :order    => :created_at.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    respond_to do |format|
      format.html
      format.js {render :template => 'account/admin/articles/search'}
    end
  end

  def destroy
    @key = dom_id(@article)
    if @article.destroy
      respond_to do |format|
        format.js {render :template => 'account/articles/destroy'}
      end
    else
      render_500
    end
  end

  def show
    @title = t('articles.show.edit_label')
  end

  def update
    elements = params[:elements]
    es = []
    s = elements.size
    s.times do |i|
      d = elements[i.to_s]
      tn = d['template_name']
      c = d['content']
      template = Template.first(:name => tn)
      raise 'Temp not found' if template.nil?
      element = Element.new(:content => c, :template => template)
      es << element
    end

    ret = @article.update_attributes!(
        :title => params[:title],
        :edited_at => Time.now,
        :elements => es
    )
    if ret
      render_format 200, :msg => t('articles.update.success')
    else
      render_format 500, t('articles.update.failed')
    end

  rescue Exception => e
    logger.error("Got a error when update #{@article} : #{e}")
    render_format 500, t('articles.update.failed')
  end

  protected
  def enter_page
    @page_index = :admin_articles
  end

  def find_article
    @article = Article.first(:id => params[:id])
    if @article.nil?
      render_404
    end
  end
end
