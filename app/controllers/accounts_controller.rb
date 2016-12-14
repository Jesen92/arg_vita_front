class AccountsController < ApplicationController
  before_filter :set_user, :set_cart

  def my_account
    @user = User.find(current_user.id)
  end

  def purchases
    @user = User.find(current_user.id)

    @all_purchases = PastPurchase.where(user_id: @user.id)

=begin
    @purchases = Klass.new
    @repro_purchases = Klass.new

    @single_article_purchases = Klass.new
    @repro_single_article_purchases = Klass.new
=end


=begin
    if !@all_purchases.empty?
      @all_purchases.each do |purchase|

        if purchase.article != nil
          if purchase.article.raw == false
            @purchases << purchase
          else
            @repro_purchases << purchase
          end
        elsif purchase.single_article != nil
          if purchase.single_article.article.raw == false
            @single_article_purchases << purchase
          else
            @repro_single_article_purchases << purchase
          end
        end

      end
    end
=end

    @purchases = PastPurchase.where("past_purchases.user_id = #{@user.id} AND past_purchases.article_id IS NOT NULL ")
    @single_article_purchases = PastPurchase.where("past_purchases.user_id = #{@user.id} AND past_purchases.single_article_id IS NOT NULL ")

    @purchases_grid = initialize_grid(@purchases, include: [:user ,:article], name: 'kupnje', order: 'past_purchases.created_at', order_direction: 'desc', per_page: 10, enable_export_to_csv: true, csv_file_name: 'Kupnje', csv_field_separator: ';' )

    @single_article_purchases_grid = initialize_grid(@single_article_purchases, include: [ :single_article, :user ], name: 'pakupnje', order: 'past_purchases.created_at', order_direction: 'desc', per_page: 10, enable_export_to_csv: true, csv_file_name: 'Kupnje', csv_field_separator: ';' )
  end

end
