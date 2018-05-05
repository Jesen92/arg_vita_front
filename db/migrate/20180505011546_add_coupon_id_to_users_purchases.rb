class AddCouponIdToUsersPurchases < ActiveRecord::Migration
  def change
    add_column :users_purchases, :coupon_id, :integer
  end
end
