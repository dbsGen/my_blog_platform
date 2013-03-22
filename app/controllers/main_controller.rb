class MainController < ApplicationController

  def home_page
    @page_index = :home
  end

  def popular_page
    @page_index = :popular
  end

  def recommend_page
    @page_index = :recommend
  end

  def last_page
    @page_index = :last
  end
end
