class AddUsersPurchaseIdToPasPurchase < ActiveRecord::Migration
  def change
    add_column :past_purchases, :users_purchase_id, :integer
  end
end
