class FixColumnNameCreditCardParams < ActiveRecord::Migration
  def self.up
    rename_column :credit_card_params, :hash, :required_hash
  end
end
