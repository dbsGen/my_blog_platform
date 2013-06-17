class MainController < ApplicationController
  layout 'home'

  def recommend
    @page_index = :recommend
    article_group = ArticleGroup.find_by_name 'recommend'
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
    @articles = q.sort(:created_at.desc).limit(per_page)
    @title = CONFIG['title']
    respond_to do |format|
      format.js {render template: 'main/home_page'}
      format.html {render template: 'main/home_page'}
    end
  end

  def remote_app
    logger.info("####  Enter by domain #{request.domain}")
    if CONFIG['home_domain'].include? request.domain and ['www', ''].include?(request.subdomain)
      hot
    else
      blog
    end
  end

  def blog
    u = user_with_domain
    if u.nil?
      render_404
    else
      @user = UserCopy.new u
      per_page = params[:per_page] || 25
      last = params[:last]
      q = last.nil? ? u.show_articles : u.show_articles.where(:created_at.lte => last)
      @articles = q.sort(:created_at.desc).limit(per_page)
      respond_to do |format|
        format.js
        format.html do
          @template = u.blog_template
          #render(:file => "#{template.dynamic_path}/skim/view/#{cf}" ,
          #       :locals => {:id => "#{template.name}_#{now}",
          #                   :element => element,
          #                   :dynamic_path => template.dynamic_path,
          #                   :static_path => template.static_path,
          #                   :template_info => template.description
          #       })
          @content_path = "#{@template.dynamic_path}/skim/view/content"
          render file: "#{@template.dynamic_path}/skim/view/layout", layout: nil
        end
      end
    end
  end

  def search
    keyword = params[:key]
    limit = params[:limit] || 5
    return render(layout: nil) if keyword.nil? or keyword.size == 0
    @articles = Article.where(title: /#{keyword}/).limit(limit)
    @users = User.where(nickname: /#{keyword}/).limit(limit)
    render(layout: nil)
  end
end
