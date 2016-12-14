class PastPurchase < ActiveRecord::Base
  belongs_to :user
  belongs_to :single_article
  belongs_to :article

end
