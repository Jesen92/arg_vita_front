class SuccessfulPurchase
  def initialize(delivery_info, user, shipping_cost, approval_code = nil)
    @delivery_info = delivery_info
    @user = user
    @shipping_cost = shipping_cost
    @approval_code = approval_code
  end

  def succesful_payment
    execute_succesful_payment
  end

  attr_reader :delivery_info, :user, :shipping_cost, :approval_code

  private

  def execute_succesful_payment
    @shopping_cart = ShoppingCart.find_by(user_id: user.id)
    @carts_article = CartsArticle.where(shopping_cart_id: @shopping_cart.id)
    coupon = Coupon.find_by(id: delivery_info['coupon_id'] ) if delivery_info['coupon_id'].present?
    @user = user

    @current_purchase_sum = @carts_article.map {|a| (a.cost.to_f*a.amount.to_f)}.inject(:+)

    @current_purchase_sum = @current_purchase_sum-(@current_purchase_sum*(coupon.discount/100.00)) if coupon.present?

    create_users_purchase
    
    @carts_article.each do |art|

      if art.article != nil
        past_purchase = PastPurchase.new(delivery_info.except('coupon_id')
          .merge({user_id: user.id, article_id: art.article.id, amount: art.amount, cost: art.cost, approval_code: approval_code, users_purchase_id: @user_purchase_id})
          )
        past_purchase.save
        article = Article.find(art.article.id)

        article.amount -= art.amount
        article.save
      elsif art.single_article != nil
        past_purchase = PastPurchase.new(delivery_info.except('coupon_id')
          .merge({user_id: user.id, single_article_id: art.single_article.id, amount: art.amount, cost: art.cost, approval_code: approval_code, users_purchase_id: @user_purchase_id}
          ))
        past_purchase.save
        article = SingleArticle.find(art.single_article.id)

        article.amount -= art.amount if article.amount
        article.save
      end
    end


    if @user.purchase_sum == nil || @user.purchase_sum == 0
      @user.purchase_sum = @current_purchase_sum
    else
      @user.purchase_sum += @current_purchase_sum
    end

    @user.save

    delivery_info.merge!({purchase_id: @user_purchase_id})
    
    UserMailer.checkout_mail(user, delivery_info).deliver_now
    coupon.update(used: true) if delivery_info['coupon_id'].present?

    @carts_article.destroy_all
    @shopping_cart.current_cost = 0
    @shopping_cart.save

    # Note that you'll need to `Payment.find` the payment again to access user info like shipping address
  end

  def create_users_purchase
    extra_cost = delivery_info['payment_method'].include?("Pri pouze") ? 5 : 0

    @user_purchase_id = UsersPurchase.create(delivery_info
      .merge({total_purchase: @current_purchase_sum, user_id: user.id, shipping_cost: @current_purchase_sum >= 400 ? 0 : 23+extra_cost })).id
  end

end