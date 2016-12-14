class CartsArticle < ActiveRecord::Base
  belongs_to :shopping_cart
  belongs_to :single_article
  belongs_to :article
  belongs_to :complement



end
