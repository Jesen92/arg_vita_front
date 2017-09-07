class AddRemarkToPastPurchases < ActiveRecord::Migration
  def change
    add_column :past_purchases, :remark, :text
  end
end
