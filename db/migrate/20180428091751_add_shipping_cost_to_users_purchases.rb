class AddShippingCostToUsersPurchases < ActiveRecord::Migration
  def change
    add_column :users_purchases, :shipping_cost, :decimal, precision: 5, scale: 2
  end
end
