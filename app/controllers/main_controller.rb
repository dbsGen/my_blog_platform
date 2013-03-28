class MainController < ApplicationController

  def home_page
    @page_index = :home
    per_page = params[:per_page] || 25
    last = params[:last]
    q = last.nil? ? Article : Article.where(:created_at.lte => params[:last])
    @articles = q.sort(:created_at.desc).limit(per_page)
    respond_to do |format|
      format.js
      format.html
    end
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
