class AddOnAuctionToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :on_auction, :boolean
  end
end
