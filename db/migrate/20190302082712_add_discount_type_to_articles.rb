class AddDiscountTypeToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :discount_type, :string
  end
end
