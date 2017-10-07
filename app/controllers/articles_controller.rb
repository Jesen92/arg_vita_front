class ArticlesController < ApplicationController
  before_filter :set_user, :set_cart, :set_main_title


  def index


    @page_title = "Artikli"
    @filterrific = initialize_filterrific(Article.where(raw: false, for_sale: true), params[:filterrific], select_options: { sorted_by: Article.options_for_sorted_by,
                                                                                                             with_category_id: Category.options_for_select,
                                                                                                             with_material_id: Material.options_for_select}) or return
    @articles = session[:filtered_articles].present? ? session[:filtered_articles] : @filterrific.find.page(params[:page])
    session[:filtered_articles] = @articles

    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return

  end


  def search_art
    if current_user == nil
      @no_articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)

    else
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )

    end

    terms = !params[:article].nil? ? params[:article][:title].to_s.downcase : session[:last_article_search]
    session[:last_article_search] = params[:article][:title].to_s.downcase unless params[:article].nil?

    if terms == "" || terms == nil
      @articles = nil
    else
      @articles = Article.where(
          "(articles.for_sale = true AND LOWER(articles.title) LIKE ? OR LOWER(articles.title_eng) LIKE ? OR LOWER(articles.code) LIKE ?)", "%#{terms}%", "%#{terms}%", "%#{terms}%"
      ).page(params[:page] || 1).per(12)
    end

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : $items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @articles.collect!(&p) unless @articles.nil?
  end

  def index_subcategories
    @page_title = "Artikli"
    @filterrific = initialize_filterrific(Article.where(raw: true,for_sale: true), params[:filterrific], select_options: { sorted_by: Article.options_for_sorted_by,
                                                                                                             with_subcategory_id: Category.options_for_select,
                                                                                                             with_ssubcategory_id: Material.options_for_select}) or return

    @articles = session[:filtered_articles].present? ? session[:filtered_articles] : @filterrific.find.page(params[:page])
    session[:filtered_articles] = @articles

    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return

  end

  #############################################################################################################################################################################

  def show_pics

  end

  def show
    if current_user == nil
      @articles = Article.where(id: $no_user_articles.keys)
      @sa = SingleArticle.where(id: $no_user_single_articles.keys)
    end

    @article = Article.find(params[:id])
   # @article = Article.all
    #@article.increment!(:counter)
  end

  def upvote
    session[:voting] = true
    liked = Article.find(params[:id])
    liked.liked_by current_user
    @favorites = current_user.votes

    respond_to do |format|
      format.js
    end
  end

  def downvote
    session[:voting] = true
    liked = Article.find(params[:id])
    liked.unliked_by current_user
    @favorites = current_user.votes

    respond_to do |format|
      format.js
    end
  end

  private
  def article_params
    params.require(:article).permit(:id, :title, :categories_id, :materials_id, :cost, :subcategories_id, :ssubcategories_id )
  end

end
