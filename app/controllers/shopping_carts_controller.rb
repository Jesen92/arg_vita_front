class ShoppingCartsController < ApplicationController
 # before_action :authenticate_user!
  before_filter :set_user, :set_cart, :set_main_title
  before_action :set_anchor
  skip_before_action :set_article_raw_session, only: [:destroy_item, :destroy_single_item, :destroy_single, :destroy, :destroy_complement, :destroy_complement_item]
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
            if @article.on_discount
              $items_cost += (@article.cost- (@article.cost*@article.discount/100))
            else
              $items_cost += @article.cost
            end
          end
        end
      else
        puts "Unutar if-else-a kada nije pronaden artikl unutar hash-a"
        $no_user_articles[params[:format]] = 1
        if @article.on_discount
          $items_cost += (@article.cost- (@article.cost*@article.discount/100))
        else
          $items_cost += @article.cost
        end
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

    cookies[:page_number] = params[:page_number]
    puts "usao sam u destroy!!!!"

    if current_user == nil

      if $no_user_articles.has_key?(@article.id.to_s)

        $no_user_articles.each do |k, v|

          if k == @article.id.to_s && v.to_i > 1
            puts "ulazi u if"
            $no_user_articles[k] -= 1
            if @article.on_discount.nil? || @article.on_discount == false || @article.discount == 0
              $items_cost -= @article.cost
            else
              $items_cost -= (@article.cost- (@article.cost*@article.discount/100))
            end
          end

          if k == @article.id.to_s && v.to_i == 1
            puts "ulazi u else"
            if @article.on_discount.nil? || @article.on_discount == false || @article.discount == 0
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

    return redirect_to :back if @carts_article.nil?

        @shopping_cart.current_cost -= @carts_article.cost

        @shopping_cart.save

      if @carts_article.amount > 1
        @carts_article.amount -= 1
        @carts_article.save
      else
        @carts_article.destroy!
      end
  end

    redirect_to :back
  end

  def destroy_single
    @single_article = SingleArticle.find(params[:id])
    amount = params[:amount].to_i

    cookies[:page_number] = params[:page_number]
    if current_user == nil
      if $no_user_single_articles.has_key?(@single_article.id)
        $no_user_single_articles.each do |k, v|
          if k == @single_article.id

            $no_user_single_articles[k] -= 1
            if @single_article.article.on_discount.nil? || @single_article.article.on_discount == false || @single_article.article.discount == 0
              $items_cost -= @single_article.article.cost
            else
              $items_cost -= (@single_article.article.cost- (@single_article.article.cost*@single_article.article.discount/100))
            end

            $no_user_single_articles.delete(k) if amount < 1
          end
        end
      end
    else
      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, single_article_id: params[:id] )

        @shopping_cart.current_cost -= @carts_article.cost

      @shopping_cart.save

      if amount == 1
        @carts_article.destroy!
      else
        @carts_article.amount -= 1
        @carts_article.save
      end
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

  def destroy_item
    @article = Article.find(params[:id])
    amount = params[:amount].to_i

    cookies[:page_number] = params[:page_number]
    #binding.pry
    puts "usao sam u destroy!!!!"

    if current_user == nil

      if $no_user_articles.has_key?(@article.id.to_s)

        $no_user_articles.each do |k, v|

          if k == @article.id.to_s
            puts "ulazi u if"

            if @article.on_discount.nil? || @article.on_discount == false || @article.discount == 0
              $items_cost -= @article.cost*amount

            else

              $items_cost -= (@article.cost- (@article.cost*@article.discount/100))*amount

            end

            $no_user_articles.delete(k)
          end

        end
      end

    else

      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, article_id: params[:id] )

        @shopping_cart.current_cost -= @carts_article.cost*amount

        @shopping_cart.save

        @carts_article.destroy!
    end

    redirect_to :back
  end



  def destroy_single_item
    @single_article = SingleArticle.find(params[:id])
    amount = params[:amount].to_i

    cookies[:page_number] = params[:page_number]
    if current_user == nil
      if $no_user_single_articles.has_key?(@single_article.id)
        $no_user_single_articles.each do |k, v|

          if k == @single_article.id

            if @single_article.article.on_discount.nil? || @single_article.article.on_discount == false || @single_article.article.discount == 0
              $items_cost -= @single_article.article.cost*amount
            else
              $items_cost -= (@single_article.article.cost- (@single_article.article.cost*@single_article.article.discount/100))*amount
            end

            $no_user_single_articles.delete(k)
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

    redirect_to :back
  end


  def destroy_complement_item
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

  def check_coupon
    coupon = Coupon.find_by("code = ? AND infinite_uses = ? OR code = ? AND number_of_uses > 0", coupon_params[:code], true, coupon_params[:code])
    
    return render json: { coupon: nil }, status: 400 unless coupon.present?
    render json: { coupon: coupon }, status: 200
  end

  private
  def cart_params
    params.require(:cart).permit(:id, :user_id, :current_cost)
  end

  def coupon_params
    params.require(:coupon).permit(:code)
  end

  def set_anchor
    env["HTTP_REFERER"] += '#articles_end'
  end
end
