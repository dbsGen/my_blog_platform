require 'errors'

class Account::Admin::ArticlesController < ApplicationController
  layout 'user_page'
  before_filter :require_admin ,:enter_page
  before_filter :find_article, :only => [:destroy, :show, :update]

  helper_method :recommend_group

  def search
    per_page = params[:per_page] || 25
    page = params[:page] || 1
    Article.all.each do |a|
      p a.key_word
    end
    articles = Article.where :key_word => /#{params[:key]}/
    @articles = articles.paginate(
        :sort     => :created_at.asc,
        :per_page => per_page,
        :page     => page,
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
        :sort     => :created_at.desc,
        :per_page => per_page,
        :page     => params[:page] || 1,
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
      template = Template.where(:name => tn).first
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

  #推荐
  def recommend
    method = request.request_method_symbol
    a_id = params[:a_id]
    @article = Article.find a_id
    case method
      when :delete
        recommend_group >> @article
      when :post
        recommend_group << @article
      else
        raise Errors::MessageError.new("不能匹配#{method.to_s}方法。")
    end
  end

  def recommend_articles
    page = params[:page] || 1
    per_page = params[:per_page] || 25
    keyword = params[:key]

    @total_page = recommend_group.articles.count / per_page.to_i + 1
    if recommend_group.articles.nil?
      @articles = []
    else
      as = keyword.nil? ? recommend_group.articles : recommend_group.articles.where(key_word: /#{keyword}/)
      @articles = as.paginate sort: :created_at.desc,
                              page: page,
                              per_page: per_page
    end
    respond_to do |format|
      format.html {render :template => 'account/admin/articles/index'}
      format.js {render :template => 'account/admin/articles/search'}
    end
  end

  def recommend_group
    @recommend_group ||= ArticleGroup.recommend_group
  end

  protected
  def enter_page
    @page_index = :admin_articles
  end

  def find_article
    @article = Article.find(params[:id])
  end
end
