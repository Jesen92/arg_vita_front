class SingleArticle < ActiveRecord::Base
  belongs_to :article

  belongs_to :color


  has_many :carts_articles
  has_many :shopping_carts, :through => :carts_articles

  has_many :past_purchases
  has_many :users, :through => :past_purchases

  has_many :pictures, :dependent => :destroy
end
