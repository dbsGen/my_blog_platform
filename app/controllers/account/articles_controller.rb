class Account::ArticlesController < ApplicationController
  layout 'user_page'
  before_filter :require_login, :enter_page
  before_filter :get_article, :only => [:destroy, :update, :show]

  def new
    @title = t('articles.new')
    @templates = current_user.usable_templates_and_check
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create

    elements = params[:elements]
    es = []
    s = elements.size
    notice_to = {}
    s.times do |i|
      d = elements[i.to_s]
      es << Element.create_with_params(d) do |user|
        notice_to[user.name] = user
      end
    end

    article = Article.new :title => params[:title],
                          :creater => current_user,
                          :created_at => Time.now,
                          :elements => es
    if article.save
      notice_to.each do |_, v|
        Notice.add_notice_from_refer_article(v, article)
      end
      render_format 200, :msg => t('articles.post.success'), :redirect_url => article_path(article)
    else
      render_format 500, t('articles.post.failed')
    end

  rescue Exception => e
    render_format 500, t('articles.post.failed')
  end

  def show
    @title = t('articles.show.edit_label')
  end

  def search
    per_page = params[:per_page] || 25
    articles = current_user.articles.where :title => /#{params[:key]}/
    @articles = articles.paginate(
        :order    => :created_at.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    @total_page = articles.count / per_page + 1
    respond_to do |format|
      format.html {render :template => 'account/articles/index'}
      format.js
    end
  end

  def index
    @title = t('articles.label')
    per_page = params[:per_page] || 25
    articles = current_user.articles
    @total_page = articles.count / per_page.to_i + 1
    @articles = articles.paginate(
        :order    => :created_at.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    respond_to do |format|
      format.html
      format.js {render :template => 'account/articles/search'}
    end
  end

  def destroy
    @key = dom_id(@article)
    @article.destroy
    respond_to do |format|
      format.js
    end
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
    @page_index = :articles
  end

  def get_article
    @article = current_user.articles.first(:id => params[:id])
    if @article.nil?
      render_404
    end
  end
end
