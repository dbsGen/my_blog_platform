class Account::ArticlesController < ApplicationController
  layout 'user_page'
  before_filter :require_confirm, :enter_page
  before_filter :get_article, :only => [:destroy, :update, :show]

  def new
    @title = t('articles.new')
    @templates = current_user.content_templates
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

    #tags
    tag_string = params[:tags] || ''
    tags = []
    tag_ids = []
    tag_string.split(',').each do |string|
      tag = Tag.find_or_create_by_label string
      tag.creater = current_user
      tag.save
      tags << tag
      tag_ids << tag.id
    end

    article = Article.new :title => params[:title],
                          :creater => current_user,
                          :created_at => Time.now,
                          :elements => es,
                          :tag_ids => tag_ids

    tags.each do |tag|
      tag.articles << article
      tag.save
    end

    current_user.insert_article article
    if article.save
      notice_to.each do |_, v|
        Notice.add_notice_from_refer_article(v, article)
      end
      render_format 200, :msg => t('articles.post.success'), :redirect_url => article_path(article)
    else
      logger.error "#### Post Article failed, #{article.errors}"
      response_string = ''
      article.errors.messages[:tags].each do |v|
        response_string << v
        response_string << "\r\n"
      end
      render_format 500, response_string
    end

  rescue Exception => e
    logger.error "#### Public article failed, #{e}"
    if e.is_a? SaveError
      render_format 500, e.message
    else
      render_format 500, t('articles.post.failed')
    end
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
        :order    => :created_at.desc,
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
