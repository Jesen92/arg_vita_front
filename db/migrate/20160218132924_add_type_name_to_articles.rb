class AddTypeNameToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :type_name, :string
  end
end
