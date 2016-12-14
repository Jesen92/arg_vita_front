class ShoppingCart < ActiveRecord::Base
  belongs_to :user

  has_many :carts_articles
  has_many :single_articles, :through => :carts_articles

  has_many :carts_articles
  has_many :articles, :through => :carts_articles

  has_many :carts_articles
  has_many :complements, :through => :carts_articles

end
