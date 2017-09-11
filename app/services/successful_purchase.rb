class SuccessfulPurchase
  def initialize(delivery_info, user)
    @delivery_info = delivery_info
    @user = user
  end

  def succesful_payment
    execute_succesful_payment
  end

  attr_reader :delivery_info, :user

  private

  def execute_succesful_payment
    @shopping_cart = ShoppingCart.find_by(user_id: user.id)
    @carts_article = CartsArticle.where(shopping_cart_id: @shopping_cart.id)
    @user = user

    @current_purchase_sum = 0

    @carts_article.each do |art|

      if art.article != nil

        @current_purchase_sum += art.cost
        past_purchase = PastPurchase.new(delivery_info.merge({user_id: user.id, article_id: art.article.id, amount: art.amount, cost: art.cost}))
        #past_purchase.save
        #article = Article.find(art.article.id)

        #article.amount -= art.amount
        #article.save

      elsif art.single_article != nil

        @current_purchase_sum += art.cost
        past_purchase = PastPurchase.new(delivery_info.merge({user_id: user.id, single_article_id: art.single_article.id, amount: art.amount, cost: art.cost}))
        #past_purchase.save
        #article = SingleArticle.find(art.single_article.id)

        #article.amount -= art.amount
        #article.save

      end

    end
=begin
    if @user.purchase_sum == nil || @user.purchase_sum == 0

      @user.purchase_sum = @current_purchase_sum

    else

      @user.purchase_sum += @current_purchase_sum

    end

    @user.save
=end
    #@carts_article.destroy_all
    #@shopping_cart.current_cost = 0
    #@shopping_cart.save

    # Note that you'll need to `Payment.find` the payment again to access user info like shipping address
  end

end