class AddCountryAndCityAndAddressAndPostalCodeAndPhoneNumAndEmailToPastPurchases < ActiveRecord::Migration
  def change
    add_column :past_purchases, :country, :string
    add_column :past_purchases, :city, :string
    add_column :past_purchases, :address, :string
    add_column :past_purchases, :postal_code, :string
    add_column :past_purchases, :phone_num, :string
    add_column :past_purchases, :email, :string
  end
end
