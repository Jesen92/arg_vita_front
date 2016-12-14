class AddPurchaseSumToUser < ActiveRecord::Migration
  def change
    add_column :users, :purchase_sum, :decimal
  end
end
