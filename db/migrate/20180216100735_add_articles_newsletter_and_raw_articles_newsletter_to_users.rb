class AddArticlesNewsletterAndRawArticlesNewsletterToUsers < ActiveRecord::Migration
  def change
    add_column :users, :articles_newsletter, :boolean
    add_column :users, :raw_articles_newsletter, :boolean
  end
end
