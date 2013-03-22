class Account::ArticlesController < ApplicationController
  layout 'user_page'
  before_filter :require_login, :enter_page

  def new
    @title = t('articles.new')
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    p "get some info #{params}"
    element = Element.new :content => params[:content]
    article = Article.new :title => params[:title],
                          :creater => current_user,
                          :created_at => Time.now,
                          :elements => [element]
    if article.save and element.save
      render_format 200, t('articles.post.success')
    else
      render_format 500, t('articles.post.failed')
    end
  end

  def show
    redirect_to article_path(params[:id])
  end

  def index
    per_page = params[:per_page] || 25
    articles = current_user.articles
    @total_page = articles.count / per_page + 1
    @users = articles.paginate(
        :order    => :created_at.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    respond_to do |format|
      format.html
      #format.js {render :template => 'account/admin/users/search'}
    end
  end

  protected
  def enter_page
    @page_index = :articles
  end
end
