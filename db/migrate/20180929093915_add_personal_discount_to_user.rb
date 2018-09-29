class AddPersonalDiscountToUser < ActiveRecord::Migration
  def change
    add_column :users, :personal_discount, :integer
  end
end
