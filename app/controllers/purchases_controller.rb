class PurchasesController < ApplicationController
  #TODO napraviti da kod kupnje isto provjeri da li ima dovoljno artikla na skladistu
  before_filter :set_user, :set_cart

  def create
    @user = User.find(current_user.id)

    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.where(shopping_cart_id: @shopping_cart.id)

    #TODO ukupna cijena bi se ovdje trebala postavljat na nulu
    @current_purchase_sum = 0

    if @carts_article == nil
      flash[:error] = "Nemate ništa u košarici!"

      return redirect_to :back
    end

    @carts_article.each do |art|

      if art.article != nil

        if art.article.on_discount == true && art.article.discount != 0

          art_cost = art.article.cost - (art.article.cost * (art.article.discount/100))

        else

          art_cost = art.article.cost

        end

        @current_purchase_sum += art_cost
        PastPurchase.create(user_id: current_user.id, article_id: art.article.id, amount: art.amount, cost: art.cost)

        article = Article.find(art.article.id)

        article.amount -= art.amount
        article.save


      elsif art.single_article != nil

        if art.single_article.article.on_discount == true && art.single_article.article.discount != 0
          art_cost = art.single_article.article.cost - (art.single_article.article.cost * (art.single_article.article.discount/100))

        else

          art_cost = art.single_article.article.cost

        end
        @current_purchase_sum += art_cost
        PastPurchase.create(user_id: current_user.id, single_article_id: art.single_article.id, amount: art.amount, cost: art.cost)

        article = SingleArticle.find(art.single_article.id)

        article.amount -= art.amount
        article.save

      end

    end


    if @user.purchase_sum == nil || @user.purchase_sum == 0

      @user.purchase_sum = @current_purchase_sum

    else

      @user.purchase_sum += @current_purchase_sum

    end

    @user.save


    @carts_article.destroy_all
    @shopping_cart.current_cost = 0
    @shopping_cart.save

    redirect_to root_path

  end



end
