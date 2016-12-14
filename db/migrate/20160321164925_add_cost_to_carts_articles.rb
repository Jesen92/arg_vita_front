class AddCostToCartsArticles < ActiveRecord::Migration
  def change
    add_column :carts_articles, :cost, :decimal
  end
end
