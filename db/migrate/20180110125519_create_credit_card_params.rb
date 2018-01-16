class CreateCreditCardParams < ActiveRecord::Migration
  def change
    create_table :credit_card_params do |t|
      t.string :target
      t.string :mode
      t.integer :store_id
      t.string :order_number
      t.string :language
      t.string :currency
      t.float :amount
      t.string :cart
      t.string :hash
      t.string :require_complete

      t.timestamps null: false
    end
  end
end
