class TagsController < ApplicationController
  before_filter :require_login, only: [:create, :destroy]
  layout 'home'

  caches_page :index, expires_in: 1.hour

  def index
    @tags = Tag.paginate(per_page: 40, order: :index_score.asc, page: 0)
    render layout: false
  end

  def show
    @tag = Tag.find_by_id params[:id]
    @title = "Tag: #{@tag.label}"
    if @tag.nil?
      @articles = []
    else
      per_page = params[:per_page] || 25
      last = params[:last]
      q = last.nil? ? @tag.articles : @tag.articles.where(:created_at.lte => last)
      @articles = q.sort do |a, b|
        b.created_at <=> a.created_at
      end[0..per_page]
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  def create
    label = params[:label]
    @article = Article.find_by_id params[:article_id]
    @tag = Tag.add_tag_on_article label, @article, current_user
    expire_page controller: 'tags', action: 'index'
  end

  def destroy
    label = params[:id]
    @article = Article.find_by_id params[:article_id]
    Tag.remove_tag_from_article label, @article
    expire_page controller: 'tags', action: 'index'
    render_format 200, '删除成功'
  rescue SaveError => e
    logger.warn("#### Delete tag failed, #{e}")
    render_format 500, e.message
  rescue StandardError => e
    logger.error "#### Delete tag failed, #{e}"
    render_format 500, '删除失败！'
  end
end
