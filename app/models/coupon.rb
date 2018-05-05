class Coupon < ActiveRecord::Base
  belongs_to :article
  has_many :users_purchases
end
