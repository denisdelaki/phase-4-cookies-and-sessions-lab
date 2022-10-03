class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    article = Article.find(params[:id])
    #If this is the first request this user has made, set session[:page_views] to an initial value of 0
    session[:page_views] ||=0
    #For every request to /articles/:id, increment the value of session[:page_views] by 1.
    session[:page_views] +=1 
    #If the user has viewed fewer than 3 pages, render a JSON response with the article data.
    if session[:page_views]<4 
      render json: article
    else 
     render json: {error: "Maximum pageview limit reached"}, status: :unauthorized
    end
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

end
