class AddLastOrderNumberToShoppingCart < ActiveRecord::Migration
  def change
    add_column :shopping_carts, :last_order_number, :string
  end
end
