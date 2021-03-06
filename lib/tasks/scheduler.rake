namespace :scheduler do
  desc "Postavlja/Miče popuste ovisno o start_date i end_date artikla"

  task set_discount: :environment do
    puts "Ušao u set discount!"

    @articles = Article.where(for_sale: true)

    Article.where("for_sale = ? AND end_date < ?", true, DateTime.now).update_all(on_discount: false)
  end

  task set_auction: :environment do

    @auctions = Auction.all

    @auctions.each do |auction|


      if auction.on_auction == false

        if auction.start_date != nil && auction.start_date.to_datetime <= DateTime.now && auction.end_date.to_datetime >= DateTime.now
          auction.update(on_auction: true)
        end

      else

        puts "Aukcija je gotova, user #{auction.user.name} je dobio na aukciji!"

          if auction.end_date != nil && auction.end_date.to_datetime <= DateTime.now
            auction.update(on_auction: false)
            shopping_cart = ShoppingCart.find_by(user_id: auction.user.id)
            cost = shopping_cart.current_cost != nil ? shopping_cart.current_cost+auction.highest_bid : auction.highest_bid
            shopping_cart.update(current_cost: cost)
            CartsArticle.create(article_id: auction.article.id, shopping_cart_id: shopping_cart.id, amount: 1, cost: auction.highest_bid)
          end

      end

    end

  end

end
