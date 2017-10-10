class TrgovinaController < ApplicationController
  include ApplicationHelper
  before_filter :set_user, :set_cart, :set_main_title
  skip_before_action :set_article_raw_session, only: [:index]

  helper_method :index

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Gotov nakit", :trgovina_index_path

  def categories
    if current_user == nil
      @no_articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)

    else
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )

    end


    ########################################################## dodan za search ###########################################################
    @page_title = "Artikli"
    @filterrific = initialize_filterrific(Material.all, params[:filterrific]) or return
    @materials = @filterrific.find.page(params[:page])

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
    @categories = Category.all
    @materials = Material.all

    puts "Usao je u trgovina#index"

    if current_user != nil
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

      puts "Shopping cart ID: #{@shopping_cart.id}"

      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
    else
      puts "NEMA USER-A!!!!"

      @no_articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)
    end



    if params[:id] != nil
      $material_id = params[:id]
    end

    gon.max = Article.where(raw: false, for_sale: true, material_id: $material_id ).order(cost: :desc).pluck(:cost).first.to_f.ceil

    puts "Najveca cijena je #{gon.max}"

    gon.min = Article.where(raw: false, for_sale: true, material_id: $material_id ).order(:cost).pluck(:cost).first.to_f.ceil

    puts "Najmanja cijena je #{gon.min}"

        # filterific ###########################################################################################################################
    @page_title = "Artikli"
    @filterrific = initialize_filterrific(Article.where(raw: false, for_sale: true, material_id: $material_id ), params[:filterrific], select_options: { sorted_by: Article.options_for_sorted_by,
                                                                                                                                                       with_category_id: Category.options_for_select,
                                                                                                                                                       with_material_id: Material.options_for_select,
                                                                                                                                                         with_color_id: Color.options_for_select,
                                                                                                                                                         with_type_id: Type.options_for_select},:persistence_id => false,) or return



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
    if session[:article_raw].nil? || session[:article_raw]
      session[:article_raw] = false
      ( redirect_to(reset_filterrific_url(format: :html))and  return) unless (session[:voting].present? && (env["HTTP_REFERER"].exclude?('trgovina/index') || env["HTTP_REFERER"].exclude?('favorites/index')))
    end

    add_breadcrumb "Gotov nakit", :trgovina_index_path

    @categories = Category.all
    @materials = Material.all

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
      $material_id = params[:id]
    end

    # filterific ###########################################################################################################################
    @page_title = "Artikli"

    articles = Article.where(raw: false, for_sale: true ).includes(:pictures, :picture)

    @filterrific = initialize_filterrific(articles, params[:filterrific], select_options: { sorted_by: Article.options_for_sorted_by,
                                                                                                                                                         with_category_id: Category.options_for_select,
                                                                                                                                                         with_material_id: Material.options_for_select,
                                                                                                                                                         with_color_id: Color.options_for_select,
                                                                                                                                                         with_type_id: Type.options_for_select},
                                                                                                                                                          persistence_id: true,) or return

    gon.min, gon.max = articles.order(cost: :desc).pluck(:cost).to_a.minmax

    #min, max = !params[:filterrific].nil? && !params[:filterrific][:min_cost].nil? ? params[:filterrific][:min_cost].nil?.to_s.split(';') : nil

    @articles = session[:page_number].present? ? @filterrific.find.page(params[:page]).per(9*session[:page_number].to_i) : @filterrific.find.page(params[:page])

    #binding.pry

    gon.current_min, gon.current_max = @filterrific.find.order(cost: :desc).pluck(:cost).to_a.minmax

    #binding.pry

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : $items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @articles.collect!(&p)

    session[:article_raw] = false
    session[:voting] = nil

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

        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
      else
        puts "NEMA USER-A!!!!"
        @no_articles = Article.where(id: $no_user_articles.keys)

        @sa = SingleArticle.where(id: $no_user_single_articles.keys) # single article dodan ####################################################################################################
      end
    else
      flash[:error] = "Taj artikl ne postoji!"
      return redirect_to :back
    end
    @main_title = 'AV|'+@article.title.split.map(&:capitalize).join(' ')

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : $items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @article = p.call(@article)

  end
end
