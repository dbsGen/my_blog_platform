class ArticlesController < ApplicationController
  layout 'home'

  def show
    @article = Article.first(:id => params[:id])
    @article.check
    @comments = @article.comments.sort(:flood.desc)
    u = user_with_domain
    if u.nil?
      @title = "#{@article.title} - 我的博卡"
    else
      @title = "#{@article.title} - 我的博卡"
      @template = u.blog_template
      @content_path = "#{@template.dynamic_path}/skim/view/article"
      render file: "#{@template.dynamic_path}/skim/view/layout", layout: nil
    end
  end

end
