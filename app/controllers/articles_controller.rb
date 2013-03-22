class ArticlesController < ApplicationController

  def show
    @article = Article.first(:id => params[:id])
  end

end
