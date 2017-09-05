module ApplicationHelper
  def get_discount(params)
    DiscountPercentage.new(params).get_discount
  end
end


