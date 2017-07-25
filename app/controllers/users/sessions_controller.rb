class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    #set_user_for_adding_items_to_shopping_cart(params[:user][:email])
    #sign_in_count = @user.blank? ? 0 : @user.sign_in_count
    super

    #add_session_items_to_shopping_cart unless @user.blank? || @user.sign_in_count < sign_in_count
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  def set_user_for_adding_items_to_shopping_cart(email)
    @user = User.find_by(email: email)
  end

  def add_session_items_to_shopping_cart
    shopping_cart = @user.shopping_cart

    $no_user_articles.each do |k, v|
      cost = get_article_cost(k)
      shopping_cart.carts_articles.create(article_id: k, cost: cost, amount: v)
      shopping_cart.update(current_cost: shopping_cart.current_cost+cost*v)
    end

    $no_user_single_articles.each do |k, v|
      cost = get_single_article_cost(k)
      shopping_cart.carts_articles.create(single_article_id: k, cost: cost, amount: v)
      shopping_cart.update(current_cost: shopping_cart.current_cost+cost*v)
    end
  end

  def get_article_cost(article_id)
    article = Article.find(article_id)

    if article.on_discount
      (article.cost- (article.cost*article.discount/100))
    else
      article.cost
    end
  end

  def get_single_article_cost(single_article_id)
    single_article = SingleArticle.find(single_article_id)

    if single_article.article.on_discount
      (single_article.article.cost- (single_article.article.cost*single_article.article.discount/100))
    else
      single_article.article.cost
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
