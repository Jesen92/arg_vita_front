class TrgovinaController < ApplicationController
  include ApplicationHelper
  before_filter :set_user, :set_cart, :set_main_title
  skip_before_action :set_article_raw_session, only: [:index, :index_of]

  helper_method :index

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Gotov nakit", :trgovina_index_path

  def categories
    @page_title = "Kategorije"
    @materials = Material.all

    respond_to do |format|
      format.html
      format.js
    end
  end

  def index_of
    if params[:id] != nil
      @material_id = params[:id]
      session[:material_id] = params[:id]
    else
      @material_id = session[:material_id]
    end

    if cookies[:article_raw].nil? || cookies[:article_raw].include?('true')
      session[:page_number] = nil
      cookies[:article_raw] = false
      ( redirect_to(reset_filterrific_url(format: :html))and  return) unless (session[:voting].present? && (env["HTTP_REFERER"].exclude?('trgovina/index_of') || env["HTTP_REFERER"].exclude?('favorites/index')))
    end

    session[:page_number] = nil if params[:filterrific].present?

    if params[:page].present? && session[:page_number].present? && session[:page_number].to_i > params[:page].to_i
      params[:page] = session[:page_number].to_i + 1
    else
      session[:page_number] = params[:page] if params[:page].present?
    end

    @page_number = session[:page_number].present? ? session[:page_number].to_i : 1

    if session[:page_number].present?
      @page_number = params[:page].to_i if params[:page].present?
    elsif params[:page].present?
      @page_number = params[:page].to_i
    end

    @categories = Category.all
    @materials = Material.all

    if current_user != nil
      @shopping_cart = current_user.shopping_cart

      puts "Shopping cart ID: #{@shopping_cart.id}"

      #@carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
      @carts_article = @shopping_cart.carts_articles
    else

      @no_articles = Article.where(id: @no_user_articles.keys)
      @sa = SingleArticle.where(id: @no_user_single_articles.keys)
    end

    if params[:id] != nil
      @material_id = params[:id]
      session[:material_id] = params[:id]
    else
      @material_id = session[:material_id]
    end

    # filterific ###########################################################################################################################
    @page_title = "Artikli"

    articles = Article.where("raw= false and for_sale= true and amount > 0 and material_id = ?", @material_id).includes(:pictures, :picture)

    if articles.blank?
      flash[:error] = "Trenutno nema artikla u toj kategoriji!"

      return redirect_to categories_trgovina_index_path
    end

    @filterrific = initialize_filterrific(articles, params[:filterrific], select_options: { sorted_by: Article.options_for_sorted_by,
                                                                                            with_category_id: Category.options_for_select,
                                                                                            with_material_id: Material.options_for_select,
                                                                                            with_color_id: Color.options_for_select,
                                                                                            with_type_id: Type.options_for_select},
                                          persistence_id: true,) or return

    gon.min, gon.max = articles.order(cost: :desc).pluck(:cost).to_a.minmax

    #min, max = !params[:filterrific].nil? && !params[:filterrific][:min_cost].nil? ? params[:filterrific][:min_cost].nil?.to_s.split(';') : nil

    @articles = params[:page].blank? ? @filterrific.find.page(1).per(18*@page_number.to_i) : @filterrific.find.page(@page_number)

    ( redirect_to(reset_filterrific_url(format: :html))and  return) if @articles.blank?

    gon.current_min, gon.current_max = @filterrific.find.order(cost: :desc).pluck(:cost).to_a.minmax

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @articles.collect!(&p)

    cookies[:article_raw] = false
    session[:voting] = nil

    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    #redirect_to(reset_filterrific_url(format: :html)) and return

    ###########################################################################################################################
  end

  def index
    if cookies[:article_raw].nil? || cookies[:article_raw].include?('true')
      session[:page_number] = nil
      cookies[:article_raw] = false
      ( redirect_to(reset_filterrific_url(format: :html))and  return) unless (session[:voting].present? && (env["HTTP_REFERER"].exclude?('trgovina/index') || env["HTTP_REFERER"].exclude?('favorites/index')))
    end

    add_breadcrumb "Gotov nakit", :trgovina_index_path

    session[:page_number] = nil if params[:filterrific].present?

    if params[:page].present? && session[:page_number].present? && session[:page_number].to_i > params[:page].to_i
      params[:page] = session[:page_number].to_i + 1
    else
      session[:page_number] = params[:page] if params[:page].present?
    end

    @page_number = session[:page_number].present? ? session[:page_number].to_i : 1

    if session[:page_number].present?
      @page_number = params[:page].to_i if params[:page].present?
    elsif params[:page].present?
      @page_number = params[:page].to_i
    end

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

      @no_articles = Article.where(id: @no_user_articles.keys)
      @sa = SingleArticle.where(id: @no_user_single_articles.keys)
    end

    if params[:id] != nil
      @material_id = params[:id]
    end

    # filterific ###########################################################################################################################
    @page_title = "Artikli"

    articles = Article.where("raw= false and for_sale= true and amount > 0").includes(:pictures, :picture)

    @filterrific = initialize_filterrific(articles, params[:filterrific], select_options: { sorted_by: Article.options_for_sorted_by,
                                                                                           with_category_id: Category.options_for_select,
                                                                                           with_material_id: Material.options_for_select,
                                                                                           with_color_id: Color.options_for_select,
                                                                                           with_type_id: Type.options_for_select},
                                                                                            persistence_id: true,) or return

    gon.min, gon.max = articles.order(cost: :desc).pluck(:cost).to_a.minmax

    #min, max = !params[:filterrific].nil? && !params[:filterrific][:min_cost].nil? ? params[:filterrific][:min_cost].nil?.to_s.split(';') : nil

    @articles = params[:page].blank? ? @filterrific.find.page(1).per(18*@page_number.to_i) : @filterrific.find.page(@page_number)

    ( redirect_to(reset_filterrific_url(format: :html))and  return) if @articles.blank?

    gon.current_min, gon.current_max = @filterrific.find.order(cost: :desc).pluck(:cost).to_a.minmax

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @articles.collect!(&p)

    cookies[:article_raw] = false
    session[:voting] = nil
    puts "prosao"
    respond_to do |format|
      format.html
      format.js
    end
  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    #redirect_to(reset_filterrific_url(format: :html)) and return

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
        @no_articles = Article.where(id: @no_user_articles.keys)

        @sa = SingleArticle.where(id: @no_user_single_articles.keys) # single article dodan ####################################################################################################
      end
    else
      flash[:error] = "Taj artikl ne postoji ili trenutno nije na skladištu!"
      return redirect_to :back if env['HTTP_REFERER'].present?
      return redirect_to trgovina_index_path
    end
    @main_title = 'AV|'+@article.title.split.map(&:capitalize).join(' ')

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @article = p.call(@article)

  end
end
