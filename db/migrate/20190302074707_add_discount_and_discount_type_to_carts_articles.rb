class AddDiscountAndDiscountTypeToCartsArticles < ActiveRecord::Migration
  def change
    add_column :carts_articles, :discount, :integer
    add_column :carts_articles, :discount_type, :string
  end
end
