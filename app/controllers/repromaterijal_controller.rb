class RepromaterijalController < ApplicationController
  include ApplicationHelper
  before_filter :set_user, :set_cart, :set_main_title
  skip_before_action :set_article_raw_session, only: [:index]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Repromaterijal", :repromaterijal_index_path

  def categories
    if current_user == nil
      @no_articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)

    else
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id)

    end

    ########################################################## dodan za search ###########################################################
    @page_title = "Artikli"
    @filterrific = initialize_filterrific(Subcategory.all, params[:filterrific]) or return
    @subcategories = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
    ############################################################################################################################################


  end


  def index_of


    @ssubcategories = Ssubcategory.where(id: SsubcategorySubcategory.where(subcategory_id: params[:id]).pluck(:ssubcategory_id))
    @subcategories = Subcategory.all

    puts "Usao je u trgovina#index"

    if current_user != nil
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

      puts "Shopping cart ID: #{@shopping_cart.id}"

      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id)
    else
      puts "NEMA USER-A!!!!"

      @no_articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)
    end

    if params[:id] != nil
      $subcategory_id = params[:id]
    end

    gon.min, gon.max = Article.where(raw: true, for_sale: true, subcategory_id: $subcategory_id).pluck(:cost).to_f.ceil.minmax

    puts "Najveca cijena je #{gon.max}"

    puts "Najmanja cijena je #{gon.min}"

    # filterific ###########################################################################################################################
    @page_title = "Artikli"
    @filterrific = initialize_filterrific(Article.where(raw: true, for_sale: true, subcategory_id: $subcategory_id), params[:filterrific], select_options: {sorted_by: Article.options_for_sorted_by,
                                                                                                                                                            with_subcategory_id: Subcategory.options_for_select,
                                                                                                                                                            with_ssubcategory_id: Ssubcategory.options_for_select,
                                                                                                                                                            with_color_id: Color.options_for_select,
                                                                                                                                                            with_type_id: Type.options_for_select}) or return


    @articles = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end


  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return

    ###########################################################################################################################

  end

  def index
    if cookies[:article_raw].nil? || cookies[:article_raw].include?('false')
      #binding.pry
      cookies[:article_raw] = true
      ( redirect_to(reset_filterrific_url(format: :html))and  return) unless (session[:voting].present? && (env["HTTP_REFERER"].exclude?('trgovina/index') || env["HTTP_REFERER"].exclude?('favorites/index')))
    end

    #params[:filterrific][:reset_filterrific] = false if params[:filterrific].present? && params[:filterrific][:reset_filterrific].present?
    #binding.pry

    @page_number ||= params[:page]
    cookies[:page_number] = nil if params[:filterrific].present?

    add_breadcrumb "Repromaterijal", :repromaterijal_index_path

    @ssubcategories = Ssubcategory.all
    @subcategories = Subcategory.all

    if params[:page].present? && cookies[:page_number].present? && params[:page].to_i < cookies[:page_number].to_i
      params[:page] = (cookies[:page_number].to_i+1).to_s
      #binding.pry
    end

    puts "Usao je u trgovina#index"

    if current_user != nil
      @shopping_cart = current_user.shopping_cart

      puts "Shopping cart ID: #{@shopping_cart.id}"

      #@carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
      @carts_article = @shopping_cart.carts_articles
    else
      puts "NEMA USER-A!!!!"

      @no_articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)
    end

    if params[:id] != nil
      $subcategory_id = params[:id]
    end

    puts "Najmanja cijena je #{gon.min}"
    $ssub = nil

    if params[:filterrific]
      $ssub = params[:filterrific][:with_subcategory_id]
    end
    puts "SSUB JE #{$ssub}"

    #binding.pry
    # filterific ###########################################################################################################################
    @page_title = "Artikli"

    articles = Article.where("raw = true and for_sale = true and amount > 0").includes(:picture)

        @filterrific = initialize_filterrific(articles, params[:filterrific], select_options: {sorted_by: Article.options_for_sorted_by,
                                                                                                with_subcategory_id: Subcategory.options_for_select,
                                                                                                with_ssubcategory_id: Ssubcategory.options_for_select,
                                                                                                with_color_id: Color.options_for_select,
                                                                                                with_type_id: Type.options_for_select}, :persistence_id => true,) or return

    @articles = cookies[:page_number].present? ? @filterrific.find.page(params[:page]).per(9*cookies[:page_number].to_i) : @filterrific.find.page(params[:page])

    #cookies[:page_number] = nil

    ( redirect_to(reset_filterrific_url(format: :html))and  return) if @articles.blank?

    gon.min, gon.max = articles.order(cost: :desc).pluck(:cost).to_a.minmax

    gon.current_min, gon.current_max = @filterrific.find.order(cost: :desc).pluck(:cost).to_a.minmax

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : $items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @articles.collect!(&p)

    cookies[:article_raw] = true
    session[:voting] = nil

    respond_to do |format|
      format.html
      format.js
    end
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"

    ###########################################################################################################################

  end

  def show
    @article = Article.find_by(id: params[:format], for_sale: true)

    if @article != nil
      rel_art_ids = []
      @rel_arts = []

      rel_art_ids = RelatedArticle.where(article_id: @article.id).pluck(:related_article_id)

      @rel_arts = Article.where(id: rel_art_ids)

      if current_user != nil
        @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

        puts "Shopping cart ID: #{@shopping_cart.id}"

        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id)
      else
        puts "NEMA USER-A!!!!"
        @articles = Article.where(id: $no_user_articles.keys)
        @sa = SingleArticle.where(id: $no_user_single_articles.keys)

      end
    else
      flash[:error] = "Taj artikl ne postoji!"
      redirect_to :back
    end

  end
end
