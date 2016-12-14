class HomeController < ApplicationController
  before_filter :set_user, :set_cart

  def index
    add_breadcrumb "Home", :root_path

    if user_signed_in?
       @cart = ShoppingCart.where(user_id: current_user.id)

      if @cart.empty?
        ShoppingCart.create(user_id: current_user.id)
       end
    end

    if params[:format] != nil
    @article = Article.find(params[:format])
    end

    @categories = Category.all
    @articles = Article.where(raw: false, for_sale: true).order('created_at DESC')

    if current_user != nil
    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
    else
      @no_articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)
    end

  end

  def general
    if user_signed_in?
      @cart = ShoppingCart.where(user_id: current_user.id)

      if @cart.empty?
        ShoppingCart.create(user_id: current_user.id)
      end
    end

  end

  def download_pdf
    send_file(
        "#{Rails.root}/public/assets/Obrazac-za-jednostrani-raskid-ugovora_1.pdf",
        filename: "Obrazac za jednostrani raskid ugovora.pdf",
        type: "application/pdf"
    )
  end


end
