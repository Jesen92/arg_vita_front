class AddComplementIdToCartsArticles < ActiveRecord::Migration
  def change
    add_column :carts_articles, :complement_id, :integer
  end
end
