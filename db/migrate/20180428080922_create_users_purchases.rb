class CreateUsersPurchases < ActiveRecord::Migration
  def change
    create_table :users_purchases do |t|
      t.integer :user_id
      t.decimal :total_purchase, {:precision=>5, :scale=>2}
      t.string :email
      t.string :country
      t.string :city
      t.string :county
      t.string :address
      t.string :postal_code
      t.string :phone_num
      t.string :remark
      t.string :payment_method
      t.string :approval_code

      t.timestamps null: false
    end
  end
end