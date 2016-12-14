class AddColorToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :color, :string
  end
end
