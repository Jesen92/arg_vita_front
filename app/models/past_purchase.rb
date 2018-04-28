class PastPurchase < ActiveRecord::Base
  belongs_to :user
  belongs_to :single_article
  belongs_to :article
  belongs_to :users_purchase
end
