class ApplicationController < ActionController::Base
  include ApplicationHelper
  helper_method :resource_name, :resource, :devise_mapping, :resource_class
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_user, :set_cart, :set_article_raw_session

  def default_url_options
    if Rails.env.production?
      {:host => "www.argentumvita.com"}
    else
      {}
    end
  end

  def set_article_raw_session
    cookies[:article_raw] = nil
  end

  def set_user
    if current_user
      @user = current_user
    elsif session[:no_user_articles].blank? && session[:no_user_single_articles].blank?
      @no_user_articles = Hash.new
      @no_user_articles_int = Hash.new
      @no_user_single_articles = Hash.new
      @items_cost = 0
    else
      @no_user_articles = session[:no_user_articles]
      @no_user_single_articles = session[:no_user_single_articles]
      @items_cost = session[:items_cost]
    end
  end

  def set_cart
    if current_user == nil
      @no_articles = Article.where(id: @no_user_articles.keys) unless @no_user_articles.blank?
      @sa = SingleArticle.where(id: @no_user_single_articles.keys) unless @no_user_single_articles.blank?
    else
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
      deleteArticlesWithoutAmount

      if @shopping_cart.current_cost < 0 || @carts_article.nil?
        @shopping_cart.update(current_cost: 0)
      end

      discount = current_user.purchase_sum  < 1000 ? 5 : (((current_user.purchase_sum.to_i/500).round*500)/100)
      discount = 0 if current_user.purchase_sum < 500
      discount = 30 if discount > 30
      flash[:discount_notice] = discount > 0 ? '<span style="color: #348877;">Svojom vjernosti ostvarili ste popust od <span style="font-size: 150%; color: #515151;"> '+discount.to_s+'%</span> na sve artikle</span>' : nil
    end
  end

  def set_main_title
    @main_title = 'Argentum Vita'
  end

  private

  def deleteArticlesWithoutAmount
    @shopping_cart.carts_articles.map {|cart| cart.destroy if cart.amount.blank?}
  end
end