class AddNumberOfUsesAndInfiniteUsesToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :number_of_uses, :integer
    add_column :coupons, :infinite_uses, :bool
  end
end
