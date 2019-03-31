class ApplicationController < ActionController::Base
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  helper_method :resource_name, :resource, :devise_mapping, :resource_class
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_user, :set_cart, :set_article_raw_session, :clear_flashes, :left_to_discount

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

  def clear_flashes
    flash[:notice],flash[:warning], flash[:left_to_discount] = nil
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

      discount = current_user.personal_discount if current_user.personal_discount.present? && current_user.personal_discount > 0

      flash[:discount_notice] = discount > 0 ? '<span style="color: #348877;">Svojom vjernosti ostvarili ste popust od <span style="font-size: 150%; color: #515151;"> '+discount.to_s+'%</span> na sve artikle</span>' : nil
    end
  end

  def set_main_title
    @main_title = 'Argentum Vita'
  end

  def left_to_discount
    shopping_cart_sum = user_signed_in? ? current_user.shopping_cart.current_cost : @items_cost
    @sum_discount = SumDiscount.where('? < sum', shopping_cart_sum).order('sum ASC').first

    if @sum_discount
      sum_left = number_to_currency((@sum_discount.sum -  shopping_cart_sum) , :unit => 'Kn', :format => "%n %u")
      @sum_until_discount = '<span style="color: #348877;"><span style="font-size: 150%; color: #515151;"> '+ sum_left +'</span> preostalo do popusta od <span style="font-size: 150%; color: #515151;"> '+@sum_discount.discount.to_s+'%</span> na svaki sljedeći artikl</span>'

      flash[:left_to_discount] = @sum_until_discount
    end
  end

  def check_if_sum_discount_is_valid
    if current_user
      carts_articles = CartsArticle.where(shopping_cart_id: @shopping_cart.id)
      articles_with_discount = carts_articles.where(discount_type: 'sum_discount')

      return if articles_with_discount.blank?

      articles_with_discount.each do |article|
        if article.article.present?
          art = Article.find(article.article.id)
        else
          art = SingleArticle.find(article.single_article.id).article
        end

        discount_params = {article_discount: art.on_discount? ? art.discount : 0, current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
        discount = get_discount(discount_params)

        if article.discount != discount[:discount]
          article_cost = art.cost

          if discount[:discount] == 0
            article.cost = article_cost
            article.discount = 0
            article.discount_type = ''
          else
            cost = (article_cost - (article_cost*discount[:discount]/100)).round(2)

            article.cost = cost
            article.discount = discount[:discount]
            article.discount_type = discount[:discount_type]
          end

          article.save
        end
      end

      @shopping_cart.current_cost = carts_articles.map {|a| a.cost*a.amount}.inject(:+)
      @shopping_cart.save
    end
  end

  private

  def deleteArticlesWithoutAmount
    @shopping_cart.carts_articles.map {|cart| cart.destroy if cart.amount.blank?}
  end
end