class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
   def create
     super
     set_user_for_adding_items_to_shopping_cart(params[:user][:email])

     add_session_items_to_shopping_cart unless @user.blank? || !@user.shopping_cart.carts_articles.empty?
   end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end
  private

  def sign_up_params
    params.require(:user).permit(:name, :date_of_birth, :state, :city, :address, :postcode, :phone, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name, :date_of_birth, :state, :city, :address, :postcode, :phone, :email, :password, :password_confirmation, :current_password)
  end

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
  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
