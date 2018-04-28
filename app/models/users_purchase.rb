class UsersPurchase < ActiveRecord::Base
  has_many :past_purchase
  belongs_to :user
end
