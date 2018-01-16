class AddApprovalCodeToPastPurchase < ActiveRecord::Migration
  def change
    add_column :past_purchases, :approval_code, :string
  end
end
