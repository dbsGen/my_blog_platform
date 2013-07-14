require 'errors'

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
    return raise Errors::MessageError.new('内容不能为空') if s == 0
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
    tag_string.split(',').each do |string|
      tag = Tag.where(label: string).first
      if tag.nil?
        tag = Tag.new label: string
        expire_action controller: '/tags', action: 'index'
      end
      tag.creater = current_user
      tag.save
      tags << tag
    end

    article = Article.new :title => params[:title],
                          :creater => current_user,
                          :created_at => Time.now,
                          :elements => es,
                          :tags => tags

    tags.each do |tag|
      tag.articles << article
      tag.save
    end
    article.update_key_word

    logger.info "####Insert it to user #{current_user}"
    current_user.insert_article article
    if article.save
      # 添加应用消息
      notice_to.each do |_, v|
        Notice.add_notice_from_refer_article(v, article)
      end
      # 添加关注者的消息
      current_user.followers.each do |user|
        Notice.add_article user, article
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
    if e.is_a? Errors::SaveError
      render_format 500, e.message
    else
      render_format 500, t('articles.post.failed')
    end
  end

  def show
    @title = t('articles.show.edit_label')
    @templates = current_user.content_templates
  end

  def search
    per_page = params[:per_page] || 25
    articles = current_user.articles.where :key_word => /#{params[:key]}/
    @articles = articles.paginate(
        :sort     => :created_at.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    @total_page = articles.count / per_page + 1
    render layout: nil
  end

  def index
    @title = t('articles.label')
    per_page = params[:per_page] || 25
    articles = current_user.articles
    @total_page = articles.count / per_page.to_i + 1
    @articles = articles.paginate(
        :sort     => :created_at.desc,
        :per_page => per_page,
        :page     => params[:page],
    )
    respond_to do |format|
      format.html
      format.js {render :template => 'account/articles/search'
      }
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
    return raise Errors::MessageError.new('内容不能为空') if s == 0
    s.times do |i|
      d = elements[i.to_s]
      es << Element.create_with_params(d)
    end
    @article.title = params[:title]
    @article.edited_at = Time.now
    @article.elements = es
    @article.update_key_word
    ret = @article.save
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
    @article = current_user.articles.find(params[:id])
  end
end
