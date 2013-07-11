class MainController < ApplicationController
  layout 'home'

  def recommend
    @page_index = :recommend
    article_group = ArticleGroup.where(name: 'recommend').first
    @articles = article_group.nil? ? [] : article_group.articles
    @title = CONFIG['title']
    respond_to do |format|
      format.js {render template: 'main/home_page'}
      format.html {render template: 'main/home_page'}
    end
  end

  def time_line
    @page_index = :time_line
    per_page = params[:per_page] || 25
    last = params[:last]
    q = last.nil? ? Article.where(public: true) : Article.where(:created_at.lte => last, public: true)
    @articles = q.sort(:created_at.desc).limit(per_page)
    @title = CONFIG['title']
    respond_to do |format|
      format.js {render template: 'main/home_page'}
      format.html {render template: 'main/home_page'}
    end
  end

  def hot
    @page_index = :hot
    per_page = params[:per_page] || 25
    last = params[:last]
    q = last.nil? ? Article : Article.where(:created_at.lte => last)
    @articles = q.desc(:created_at).limit(per_page)
    @title = CONFIG['title']
    respond_to do |format|
      format.js {render template: 'main/home_page'}
      format.html {render template: 'main/home_page'}
    end
  end

  def search
    keyword = params[:key]
    limit = params[:limit] || 5
    return render(layout: nil) if keyword.nil? or keyword.size == 0
    @articles = Article.where(key_word: /#{keyword}/).limit(limit)
    render(layout: nil)
  end
end
