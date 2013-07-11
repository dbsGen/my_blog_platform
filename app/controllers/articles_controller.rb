class ArticlesController < ApplicationController
  layout 'home'

  def show
    @article = Article.find(params[:id])
    @article.check
    @comments = @article.comments.paginate :sort => :flood.desc,
                                           :per_page => 10,
                                           :page => 1
    @title = "#{@article.title} - 我的博卡"
  end

end
