class Auction < ActiveRecord::Base
  belongs_to :article
  belongs_to :user

  belongs_to :complement
end
