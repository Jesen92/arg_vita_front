class DiscountPercentage
  def initialize(params)
    @current_user ||= params[:current_user]
    @article_discount ||= params[:article_discount]
    @shopping_cart_sum ||= params[:shopping_cart_sum]
  end

  def get_discount
    get_maximum_discount
  end

  private

  attr_reader :current_user, :article_discount, :shopping_cart_sum

  def get_maximum_discount
    user_sum_discount = current_user.nil? || current_user.purchase_sum < 500 ? 0 : get_user_sum_discount
    shopping_cart_sum_discount = get_shopping_cart_sum_discount

    [user_sum_discount, shopping_cart_sum_discount, article_discount].max
  end

  def get_user_sum_discount
    purchase_sum = current_user.purchase_sum
    discount = purchase_sum.to_i < 1000 ? 5 : (((purchase_sum.to_i/500).round*500)/100)

    discount > 30 ? 30 : discount
  end

  def get_shopping_cart_sum_discount
    return 0 unless shopping_cart_sum >= 1000
    shopping_cart_sum > 2000 ? 30 : 20
  end

end