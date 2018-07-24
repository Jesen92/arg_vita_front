class FavoritesController < ApplicationController
  def index
    articles = Article.where(id: current_user.votes.order('id DESC').pluck(:votable_id))
    #binding.pry
    # filterific ###########################################################################################################################
    @page_title = "Artikli"
    @filterrific = initialize_filterrific(articles, params[:filterrific], select_options: {}, :persistence_id => false,) or return

    @articles = @filterrific.find.page(params[:page])
    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    @articles.collect!(&p)
    #binding.pry
  end
end
