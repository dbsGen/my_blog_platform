class ArticlesController < ApplicationController

  def show
    @article = Article.first(:id => params[:id])
    @comments = @article.comments.sort(:flood.desc)
  end

end
