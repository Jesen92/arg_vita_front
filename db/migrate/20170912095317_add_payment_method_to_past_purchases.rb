class AddPaymentMethodToPastPurchases < ActiveRecord::Migration
  def change
    add_column :past_purchases, :payment_method, :string
  end
end
