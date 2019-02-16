class CreateSumDiscounts < ActiveRecord::Migration
  def change
    create_table :sum_discounts do |t|
      t.integer :sum
      t.integer :discount

      t.timestamps null: false
    end
  end
end
