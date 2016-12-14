class ShoppingCartsController < ApplicationController
 # before_action :authenticate_user!
  before_filter :set_user, :set_cart
  def index


  end

  def show
    if current_user == nil
      #$no_user_articles.each do |k, v|
        @no_articles = Article.where(id: $no_user_articles.keys)

        @sa = SingleArticle.where(id: $no_user_single_articles.keys)

      $no_user_single_articles.each do |k,v|
        puts "#{k}"
      end

    else
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id )
    end

  end

  def new

  end



  def create
    if current_user == nil

      @article = Article.find(params[:format])


      puts "Ispred if za provjeru jel se artikl nalazi u hash-u"
      if $no_user_articles.has_key?(@article.id.to_s)
        $no_user_articles.each do |k, v|
          if k == @article.id.to_s
            $no_user_articles[k] += 1
            $items_cost +=@article.cost
          end
        end
      else
        puts "Unutar if-else-a kada nije pronaden artikl unutar hash-a"
        $no_user_articles[params[:format]] = 1
        $items_cost +=@article.cost
      end



    else


      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: params[:format] )

      if @carts_article == nil
        CartsArticle.create(shopping_cart_id: @shopping_cart.id, article_id: params[:format], amount: 1 )
        @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: params[:format] )
      else
        @carts_article.increment!(:amount)
      end



      @article = Article.find(params[:format])
      #@carts_articles = CartsArticle.all



      if @article.on_discount.nil? || @article.on_discount == false || @article.discount != 0
        if current_user == nil

          $items_cost += @article.cost

        else
          @shopping_cart.current_cost += @article.cost
          @shopping_cart.save
        end
      else
        if current_user == nil

          $items_cost += (@article.cost- (@article.cost*@article.discount/100))

        end
        @shopping_cart.current_cost += (@article.cost- (@article.cost*@article.discount/100))
        @shopping_cart.save
      end




    end



    redirect_to :back

  end

  def edit
  end

  def update

  end

  def destroy
    @article = Article.find(params[:format])

    puts "usao sam u destroy!!!!"

    if current_user == nil

      if $no_user_articles.has_key?(@article.id.to_s)

        $no_user_articles.each do |k, v|

          if k == @article.id.to_s && v.to_i > 1
            puts "ulazi u if"
            $no_user_articles[k] -= 1
            if @article.on_discount.nil? || @article.on_discount == false || @article.discount != 0
              $items_cost -= @article.cost

            else

              $items_cost -= (@article.cost- (@article.cost*@article.discount/100))

            end
          end

          if k == @article.id.to_s && v.to_i == 1
            puts "ulazi u else"
            if @article.on_discount.nil? || @article.on_discount == false || @article.discount != 0
              $items_cost -= @article.cost

            else
              $items_cost -= (@article.cost- (@article.cost*@article.discount/100))

            end
            $no_user_articles.delete(k)
          end

        end
      end

    else

    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: params[:format] )
    if @carts_article.amount > 1
      @carts_article.amount -= 1
      @carts_article.save

        @shopping_cart.current_cost -= @carts_article.cost
        @shopping_cart.save

    else

        @shopping_cart.current_cost -= @carts_article.cost
        @shopping_cart.save

      @carts_article.destroy!
    end
  end

    redirect_to :back
  end



  def destroy_single

    @single_article = SingleArticle.find(params[:format])
    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, single_article_id: params[:format] )

      puts "usao sam u destroy single"


    if @carts_article.amount > 1
      @carts_article.amount -= 1
      @carts_article.save

        @shopping_cart.current_cost -= @carts_article.cost
        @shopping_cart.save

    else

        @shopping_cart.current_cost -= @carts_article.cost
        @shopping_cart.save

      @carts_article.destroy!
    end



    redirect_to :back

  end


  def destroy_complement
    @single_article = Complement.find(params[:format])
    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, complement_id: params[:format] )

    puts "usao sam u destroy single"


    if @carts_article.amount > 1
      @carts_article.amount -= 1
      @carts_article.save
      if @single_article.on_discount.nil? || @single_article.on_discount == false || @single_article.discount != 0
        @shopping_cart.current_cost -= @single_article.cost
        @shopping_cart.save
      else
        @shopping_cart.current_cost -= (@single_article.cost- (@single_article.cost*@single_article.discount/100))
        @shopping_cart.save
      end
    else
      if @single_article.on_discount.nil? || @single_article.on_discount == false || @single_article.discount != 0
        @shopping_cart.current_cost -= @single_article.cost
        @shopping_cart.save
      else
        @shopping_cart.current_cost -= (@single_article.cost- (@single_article.cost*@single_article.discount/100))
        @shopping_cart.save
      end
      @carts_article.destroy!
    end



    redirect_to :back
  end












  private
  def cart_params
    params.require(:cart).permit(:id, :user_id, :current_cost)
  end


end
