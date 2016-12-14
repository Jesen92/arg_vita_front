class CategoriesController < ApplicationController
  before_filter :set_user, :set_cart
  def index
    @category = Category.all
    if current_user == nil
      @articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)
    end

  end

  def show
    @category = Category.find(params[:id])
    if current_user == nil
      @articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)
    end
  end


end
