class AddDeliveryInfoParamsToShoppingCart < ActiveRecord::Migration
  def change
    add_column :shopping_carts, :delivery_info_params, :longtext
  end
end
