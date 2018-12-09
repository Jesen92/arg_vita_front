module Ajax
  class ShoppingCartsController < ApplicationController
    before_filter :set_user, :set_cart, :set_main_title, :set_gon
    skip_before_action :set_article_raw_session
    after_action :set_ajax_article_session

    def create
      session[:page_number] = params[:page_number]

      @ind = false

      art_id = params[:article][:id]

      amount = !params[:article].blank? && params[:article][:amount].to_i > 0 ? params[:article][:amount].to_i : 1

      @article = Article.find(art_id)

      discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
      p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
      @article = p.call(@article)

      if amount > @article.amount
        @message = "Nema dovoljne kolicine artikla u ducanu"

        respond_to do |format|
          return format.js {flash[:error] = @message}
        end
      end

      if current_user == nil  # kad nema usera #############################################################################################

        puts "Ispred if za provjeru jel se artikl nalazi u hash-u"
        if @no_user_articles.has_key?(@article.id.to_s)
          @no_user_articles.each do |k, v|
            if k == @article.id.to_s
              if @no_user_articles[k]+amount > @article.amount
                @message = "Nema dovoljne kolicine artikla u ducanu"
                respond_to do |format|
                  return format.js {flash[:error] = @message}
                end
              end

              @no_user_articles[k] += amount
            end
          end

        else
          puts "Unutar if-else-a kada nije pronaden artikl unutar hash-a"
          @no_user_articles[art_id] = amount
        end
      else   # kad ima usera ################################################################################################################

        @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: art_id )

        puts @carts_article

        if @carts_article == nil
          if @article.amount.present? && amount <= @article.amount
            CartsArticle.create(shopping_cart_id: @shopping_cart.id, article_id: art_id, amount: params[:article] ? params[:article][:amount] : 1 )
            @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: art_id )
          else
            @message = "Nema dovoljne kolicine artikla u ducanu"

            respond_to do |format|
              return format.js {flash[:error] = @message}
            end
          end

        elsif @carts_article.amount+amount <= @article.amount
          #TODO ovdje treba promjenit provjeru za amount
          if amount+@carts_article.amount > @article.amount
            @message = "Nema dovoljne kolicine artikla u ducanu"
            respond_to do |format|
              return format.js {flash[:error] = @message}
            end
          end

          @carts_article.amount += amount
          @carts_article.save

        else
          @message = "Nema dovoljne kolicine artikla u ducanu"
          respond_to do |format|
            return format.js {flash[:error] = @message}
          end
        end
      end

      puts "Artiklu je popust: #{@article.on_discount}"

      if @article.discount == 0

        puts "NEMA POPUSTA! ! !"

        if current_user == nil

          @items_cost += @article.cost*amount

        elsif current_user != nil

          #TODO tu se dodaje samo jedna cijena ne gleda se na amount odjednom stavljenih proizvoda u kosaricu

          @shopping_cart.current_cost += @article.cost*amount
          @shopping_cart.save

          @carts_article.cost = @article.cost
          @carts_article.save

        end
      elsif
      if current_user == nil

        @items_cost += (@article.cost- (@article.cost*@article.discount/100))*amount

      elsif current_user != nil

        cost = (@article.cost- (@article.cost*@article.discount/100)).round(2)

        @shopping_cart.current_cost += cost*amount
        @shopping_cart.save

        @carts_article.cost = cost
        @carts_article.save

      end
      end

      if current_user == nil
        @no_articles = Article.where(id: @no_user_articles.keys)
        @sa = SingleArticle.where(id: @no_user_single_articles.keys)
      end

      respond_to do |format|
        format.js {flash[:notice] = "Artikl dodan u košaricu" }
      end
    end

    def create_single
      session[:page_number] = params[:page_number]
      if params[:article]
        @single_article = SingleArticle.find_by(article_id: params[:article][:id], size: params[:article][:size])
      else
        @single_article = SingleArticle.find_by(id: params[:id])
      end

      amount = params[:article].blank? ? 1 : params[:article][:amount].to_i

      discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
      p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
      @article = p.call(@single_article.article)

      if amount > @single_article.amount
        @message = "Nema dovoljne kolicine artikla u ducanu"

        respond_to do |format|
          return format.js {flash[:error] = @message}
        end
      end
      # kad ima usera #############################################################################################
      if current_user

        @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, single_article_id: @single_article.id )

        article_amount = @single_article.amount.nil? ? 9999 : @single_article.amount


        if @carts_article == nil
          puts "Samo jedan takav artikl postoji!"
          if article_amount >= amount

            @carts_article = CartsArticle.create(shopping_cart_id: @shopping_cart.id, single_article_id: @single_article.id, amount: amount)

          else
            @message = "Nema dovoljne kolicine artikla u ducanu"

            respond_to do |format|
              return format.js {flash[:error] = @message}
            end
          end

        else

          if article_amount >= @carts_article.amount+amount
            @carts_article.amount += amount
            @carts_article.save
          else
            @message = "Nema dovoljne kolicine artikla u ducanu"

            respond_to do |format|
              return format.js {flash[:error] = @message}
            end
          end
        end
        #kad nema usera   ################################################################################################################

      else
        if @no_user_single_articles.has_key?(@single_article.id)
          @no_user_single_articles.each do |k, v|
            if k == @single_article.id
              if amount+@no_user_single_articles[k] > @single_article.amount
                @message = "Nema dovoljne kolicine artikla u ducanu"

                respond_to do |format|
                  return format.js {flash[:error] = @message}
                end
              end

              @no_user_single_articles[k] += amount
            end
          end
        else
          @no_user_single_articles[@single_article.id] = amount
        end
      end
      ###################################################################################################################################

      puts "INDIKATOR JE #{@ind}"

      if @single_article.article.discount == 0

        puts "Ušao sam u normalno postavljanje cijene!"

        if current_user == nil

          @items_cost += @single_article.article.cost*amount

        else
          @shopping_cart.current_cost += @single_article.article.cost*amount
          @shopping_cart.save

          @carts_article.cost = @single_article.article.cost
          @carts_article.save
        end

      elsif
      if current_user == nil

        @items_cost += (@single_article.article.cost- (@single_article.article.cost*@single_article.article.discount/100))*amount

      else
        cost = (@single_article.article.cost- (@single_article.article.cost*@single_article.article.discount/100)).round(2)

        @shopping_cart.current_cost += cost*amount
        @shopping_cart.save

        @carts_article.cost = cost
        @carts_article.save
      end
      end

      if current_user == nil
        @no_articles = Article.where(id: @no_user_articles.keys)
        @sa = SingleArticle.where(id: @no_user_single_articles.keys)
      end

      respond_to do |format|
        format.js {flash[:notice] = "Artikl dodan u košaricu" }
      end
    end

    def destroy_item
      @article = Article.find(params[:id])
      amount = params[:amount].to_i

      cookies[:page_number] = params[:page_number]

      puts "usao sam u destroy!!!!"

      if current_user == nil

        if @no_user_articles.has_key?(@article.id.to_s)

          @no_user_articles.each do |k, v|

            if k == @article.id.to_s
              puts "ulazi u if"

              if @article.on_discount.nil? || @article.on_discount == false || @article.discount == 0
                @items_cost -= @article.cost*amount

              else

                @items_cost -= (@article.cost- (@article.cost*@article.discount/100))*amount

              end

              @no_user_articles.delete(k)
            end

          end
        end

      else
        @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: params[:id] )

        if @carts_article.nil?
          @message = "Artikl se ne nalazi u košarici!"
          respond_to do |format|
            format.js
          end
        end

        @shopping_cart.current_cost -= @carts_article.cost*amount

        @shopping_cart.save

        @carts_article.destroy!
      end

      respond_to do |format|
        format.js {flash[:warning] = "Artikl uklonjen iz košarice!" }
      end
    end

    def destroy
      @article = Article.find(params[:id])

      cookies[:page_number] = params[:page_number]
      puts "usao sam u destroy!!!!"

      if current_user == nil

        if @no_user_articles.has_key?(@article.id.to_s)

          @no_user_articles.each do |k, v|

            if k == @article.id.to_s && v.to_i > 1
              puts "ulazi u if"
              @no_user_articles[k] -= 1
              if @article.on_discount.nil? || @article.on_discount == false || @article.discount == 0
                @items_cost -= @article.cost
              else
                @items_cost -= (@article.cost- (@article.cost*@article.discount/100))
              end
            end

            if k == @article.id.to_s && v.to_i == 1
              puts "ulazi u else"
              if @article.on_discount.nil? || @article.on_discount == false || @article.discount == 0
                @items_cost -= @article.cost

              else
                @items_cost -= (@article.cost- (@article.cost*@article.discount/100))

              end
              @no_user_articles.delete(k)
            end

          end
        end

      else

        @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: params[:id] )

        if @carts_article.nil?
          @message = "Artikl se ne nalazi u košarici!"
          respond_to do |format|
            format.js
          end
        end

        @shopping_cart.current_cost -= @carts_article.cost

        @shopping_cart.save

        if @carts_article.amount > 1
          @carts_article.amount -= 1
          @carts_article.save
        else
          @carts_article.destroy!
        end
      end

      respond_to do |format|
        format.js {flash[:warning] = "Komad Artikla uklonjen iz košarice!" }
      end
    end

    def destroy_single
      @single_article = SingleArticle.find(params[:id])
      amount = params[:amount].to_i

      cookies[:page_number] = params[:page_number]
      if current_user == nil
        if @no_user_single_articles.has_key?(@single_article.id)
          @no_user_single_articles.each do |k, v|
            if k == @single_article.id

              @no_user_single_articles[k] -= 1
              if @single_article.article.on_discount.nil? || @single_article.article.on_discount == false || @single_article.article.discount == 0
                @items_cost -= @single_article.article.cost
              else
                @items_cost -= (@single_article.article.cost- (@single_article.article.cost*@single_article.article.discount/100))
              end

              @no_user_single_articles.delete(k) if amount < 1
            end
          end
        end
      else
        @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, single_article_id: params[:id] )

        if @carts_article.nil?
          @message = "Artikl se ne nalazi u košarici!"
          respond_to do |format|
            format.js
          end
        end

        @shopping_cart.current_cost -= @carts_article.cost

        @shopping_cart.save

        if amount == 1
          @carts_article.destroy!
        else
          @carts_article.amount -= 1
          @carts_article.save
        end
      end

      respond_to do |format|
        format.js {flash[:warning] = "Komad Artikla uklonjen iz košarice!" }
      end
    end

    def destroy_single_item
      @single_article = SingleArticle.find(params[:id])
      amount = params[:amount].to_i

      cookies[:page_number] = params[:page_number]
      if current_user == nil
        if @no_user_single_articles.has_key?(@single_article.id)
          @no_user_single_articles.each do |k, v|

            if k == @single_article.id

              if @single_article.article.on_discount.nil? || @single_article.article.on_discount == false || @single_article.article.discount == 0
                @items_cost -= @single_article.article.cost*amount
              else
                @items_cost -= (@single_article.article.cost- (@single_article.article.cost*@single_article.article.discount/100))*amount
              end

              @no_user_single_articles.delete(k)
            end
          end
        end

      else
        @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, single_article_id: params[:id] )

        @shopping_cart.current_cost -= @carts_article.cost*@carts_article.amount

        @shopping_cart.save
        @carts_article.destroy!
      end

      respond_to do |format|
        format.js {flash[:warning] = "Artikl uklonjen iz košarice!" }
      end
    end

    private

    def set_gon
      gon.current_min, gon.current_max = 0
      gon.min, gon.max = 0
    end

    def set_ajax_article_session
      if current_user == nil
        session[:no_user_articles] = @no_user_articles
        session[:no_user_single_articles] = @no_user_single_articles
        session[:items_cost] = @items_cost
      end
    end
  end
end

