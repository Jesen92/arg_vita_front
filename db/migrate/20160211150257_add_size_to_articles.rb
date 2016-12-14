class AddSizeToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :size, :string
  end
end
