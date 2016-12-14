class Complement < ActiveRecord::Base
  has_many :article_complements
  has_many :single_articles, :through => :article_complements

  has_many :past_purchases
  has_many :users, :through => :past_purchases

  has_many :pictures, :dependent => :destroy

  belongs_to :picture

  has_many :carts_articles
  has_many :shopping_carts, :through => :carts_articles
end
