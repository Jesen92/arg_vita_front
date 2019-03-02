module ApplicationHelper
  def get_discount(params)
    DiscountPercentage.new(params).get_discount
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def get_left_to_discount(shopping_cart_sum)
    #shopping_cart_sum = user_signed_in? ? current_user.shopping_cart.current_cost : @items_cost
    @sum_discount = SumDiscount.where('? < sum', shopping_cart_sum).order('sum ASC').first
    if @sum_discount
      sum_left = number_to_currency((@sum_discount.sum -  shopping_cart_sum) , :unit => 'Kn', :format => "%n %u")
      @sum_until_discount = '<span style="color: #348877;"><span style="font-size: 150%; color: #515151;"> '+ sum_left +'</span> preostalo do popusta od <span style="font-size: 150%; color: #515151;"> '+@sum_discount.discount.to_s+'%</span> na svaki sljedeći artikl</span>'

      return @sum_until_discount
    end

    nil
  end
end


