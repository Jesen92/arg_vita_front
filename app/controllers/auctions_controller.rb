class AuctionsController < ApplicationController
  before_filter :set_user, :set_cart

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Aukcije", :auctions_index_path


  def index
    if current_user != nil
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

      puts "Shopping cart ID: #{@shopping_cart.id}"

      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
    else
      puts "NEMA USER-A!!!!"
      @articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)

    end

    @auctions = Auction.where(on_auction: true)
  end

  def show
    if current_user != nil
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

      puts "Shopping cart ID: #{@shopping_cart.id}"

      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
    else
      puts "NEMA USER-A!!!!"
      @articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)

    end

    @auction = Auction.find(params[:id])

  end

  def complement_show
    if current_user != nil
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

      puts "Shopping cart ID: #{@shopping_cart.id}"

      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
    else
      puts "NEMA USER-A!!!!"
      @articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)

    end

    @auction = Auction.find(params[:id])

  end

  def new_bid

    if current_user != nil
    auction = Auction.find(params[:auction][:id])


    bid =  auction.highest_bid != nil ? auction.highest_bid : auction.starting_price

    if params[:auction][:highest_bid].to_f > bid

      auction.user_id = current_user.id
      auction.highest_bid = params[:auction][:highest_bid]
      auction.save

      flash[:notice] = "Uspješno ste licitirali!"

    else

      flash[:error] = "Ponuda mora biti veća od trenutne!"

    end

    else

      flash[:error] = "Morate biti ulogirani da bi licitirali!"

    end

  redirect_to :back

  end

end