class CartsArticlesController < ApplicationController
  #before_action :authenticate_user!
  before_action :set_user, :set_cart
  before_action :set_main_title, :set_anchor
  skip_before_action :set_article_raw_session
  after_action :set_article_session

  def index
  end

  def show
  end

  def new
    @carts_article = CartsArticle.new
  end

  def create
    #if current_user == nil
    #  flash[:error] = "Morate biti ulogirani da bi stavljali artikle u kosaricu!"
    #  return redirect_to :back
    #end

    session[:page_number] = params[:page_number]

    @ind = false

    art_id = params[:format] ? params[:format] : params[:article][:id]

    amount = !params[:article].blank? && params[:article][:amount].to_i > 0 ? params[:article][:amount].to_i : 1

    @article = Article.find(art_id)

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
    p = Proc.new {|article|
      discount_params[:article_discount] = article.on_discount? ? article.discount : 0
      calculated_discount = get_discount(discount_params)
      article.discount = calculated_discount[:discount]
      article.discount_type = calculated_discount[:discount_type]
      article }
    @article = p.call(@article)

    (flash[:error] = "Nema dovoljne kolicine artikla u ducanu" and return redirect_to :back) if @amount != nil && amount > @article.amount

    if current_user == nil  # kad nema usera #############################################################################################

      puts "Ispred if za provjeru jel se artikl nalazi u hash-u"
      if @no_user_articles.has_key?(@article.id.to_s)
        @no_user_articles.each do |k, v|
          if k == @article.id.to_s
            (flash[:error] = "Nema dovoljne kolicine artikla u ducanu" and return redirect_to :back) if @no_user_articles[k]+amount > @article.amount
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
          flash[:error] = "Nema dovoljne kolicine artikla u ducanu"
          return redirect_to :back
        end

      elsif @carts_article.amount+amount <= @article.amount
        #TODO ovdje treba promjenit provjeru za amount
        (flash[:error] = "Nema dovoljne kolicine artikla u ducanu" and return redirect_to :back) if amount+@carts_article.amount > @article.amount
        @carts_article.amount += amount
        @carts_article.save

      else
        flash[:error] = "Nema dovoljne kolicine artikla u ducanu"
        return redirect_to :back

      end
    end

    puts "Artiklu je popust: #{@article.on_discount}"

    if @article.discount == 0

      puts "NEMA POPUSTA! ! !"

      if current_user == nil

        @items_cost += @article.cost*amount
        #binding.pry

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

        cost = (@article.cost- (@article.cost*@article.discount/100))

        @shopping_cart.current_cost += cost*amount
        @shopping_cart.save

        @carts_article.cost = cost
        @carts_article.discount = @article.discount
        @carts_article.discount_type = @article.discount_type
        @carts_article.save

      end
    end

    redirect_to :back
  end


  def single

    #if current_user == nil
    #  flash[:error] = "Morate biti ulogirani da bi stavljali artikle u kosaricu!"
    #  return redirect_to :back
    #end
    session[:page_number] = params[:page_number]

    if current_user != nil  #kad ima usera #############################################################################################################################
    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    end

    puts "Usao sam u single!!!"

    if params[:article]

      art = Article.find_by(id: params[:article][:id])

   #TODO za artikl se ne provjerava kolicina za ukupnu cijenu

      if art.on_discount != nil && art.on_discount == true
        prize = (art.cost- (art.cost*art.discount/100))
      else
        prize = art.cost
      end
    elsif params[:complement][:id]
      art = Complement.find_by(id: params[:complement][:id])

      if art.on_discount != nil && art.on_discount == true
        prize = (art.cost- (art.cost*art.discount/100))
      else
        prize = art.cost
      end
    end

    if params[:complement]

      @cart_complement = CartsArticle.find_by(complement_id: params[:complement][:id], shopping_cart_id: @shopping_cart.id)

      #puts "Komplet #{complement.complement.nil? ? "DA NULL JE" : "NIJE NULL"}"

      if @cart_complement != nil
        @cart_complement.amount += params[:complement][:amount].to_i
        @cart_complement.save
      else
       CartsArticle.create(complement_id: params[:complement][:id], shopping_cart_id: @shopping_cart.id, amount: params[:complement][:amount])
      end

    elsif params[:article][:color] || params[:article][:size] || params[:article][:type_name]

      puts "Usao sam u single_article carts_article"

      if params[:article][:size]

        puts "Usao sam u size"

        @sa = SingleArticle.where(article_id: params[:article][:id],size: params[:article][:size] )

      elsif params[:article][:color]

        puts "Usao sam u color"

        @sa = SingleArticle.find_by("article_id = ? AND color_id = ?", params[:article][:id], params[:article][:color])

      elsif params[:article][:type_name]
        puts "Usao sam u type_name"
        @sa = SingleArticle.find_by(article_id: params[:article][:id],type_name: params[:article][:type_name])

      end

      puts "ID od single article-a je #{@sa.id}"

      if current_user != nil
        @cart_single = CartsArticle.find_by(single_article_id: @sa.id, shopping_cart_id: @shopping_cart.id)

        #puts "Komplet #{complement.complement.nil? ? "DA NULL JE" : "NIJE NULL"}"

        #TODO ne provjerava se amount na skladistu
        if @cart_single != nil
          @cart_single.amount += params[:article][:amount].to_i
          @cart_single.save
        else
          CartsArticle.create(single_article_id: @sa.id, shopping_cart_id: @shopping_cart.id, amount: params[:article][:amount])
        end
      end

    else

      if current_user != nil
        @cart_single = CartsArticle.find_by(article_id: params[:article][:id], shopping_cart_id: @shopping_cart.id)

        #puts "Komplet #{complement.complement.nil? ? "DA NULL JE" : "NIJE NULL"}"

        if @cart_single != nil
          @cart_single.amount += params[:article][:amount].to_i
          @cart_single.save
        else
          CartsArticle.create(article_id: params[:article][:id], shopping_cart_id: @shopping_cart.id, amount: params[:article][:amount] )
        end
      end
    end

    if current_user != nil
      #TODO cijena se na kraju ovdije dodaje
    @shopping_cart.current_cost += prize*params[:article][:amount].to_i
    @shopping_cart.save
    end

    if current_user == nil # dodaje single article u hash single article ##############################################################
      if @sa != nil
        puts "single article nije nil"
        if @no_user_single_articles.has_key?(@sa.id.to_s)
          puts "nasao je taj key od single article-a"
          @no_user_single_articles.each do |k, v|
            if k == @sa.id.to_s
              @no_user_single_articles[k] += 1
              puts "nasao je da postoji vec u varijabli"
            end
          end
    else
      puts "Unutar if-else-a kada nije pronaden artikl unutar hash-a"
      @no_user_single_articles[@sa.id] = 1
    end
    @items_cost+=prize
    end
    end

    @no_user_single_articles.each do |k,v|
      puts "#{k}"
    end
############################################################################################################################################

    redirect_to trgovina_index_path
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
    p = Proc.new {|article|
      discount_params[:article_discount] = article.on_discount? ? article.discount : 0
      calculated_discount = get_discount(discount_params)
      article.discount = calculated_discount[:discount]
      article.discount_type = calculated_discount[:discount_type]
      article }
    @article = p.call(@single_article.article)

    (flash[:error] = "Nema dovoljne kolicine artikla u ducanu" and return redirect_to :back) if amount > @single_article.amount
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
          flash[:error] = "Nema dovoljne kolicine artikla u ducanu"
          return redirect_to :back

        end

    else

        if article_amount >= @carts_article.amount+amount
          @carts_article.amount += amount
          @carts_article.save

        else

        flash[:error] = "Nema dovoljne kolicine artikla u ducanu"
        return redirect_to :back

        end
    end
  #kad nema usera   ################################################################################################################

    else
      if @no_user_single_articles.has_key?(@single_article.id)
        @no_user_single_articles.each do |k, v|
          if k == @single_article.id
            (flash[:error] = "Nema dovoljne kolicine artikla u ducanu" and return redirect_to :back) if amount+@no_user_single_articles[k] > @single_article.amount
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
        cost = (@single_article.article.cost- (@single_article.article.cost*@single_article.article.discount/100))

        @shopping_cart.current_cost += cost*amount
        @shopping_cart.save

        @carts_article.cost = cost
        @carts_article.discount = @article.discount
        @carts_article.discount_type = @article.discount_type
        @carts_article.save
      end
    end

    redirect_to :back
  end


  def create_complement
    session[:page_number] = params[:page_number]
    if current_user == nil
      flash[:error] = "Morate biti ulogirani da bi stavljali artikle u kosaricu!"
      return redirect_to :back
    end



    puts "USAO SAM U CREATE COMPLEMENT"

    @complement = Complement.find(params[:format])

    if current_user != nil  # kad ima usera #############################################################################################

      @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)

      @carts_article = CartsArticle.find_by(shopping_cart_id: @shopping_cart.id, complement_id: params[:format] )


        @carts_article.increment!(:amount)


    else  #kad nema usera   ################################################################################################################


      if @no_user_articles.has_key?(@complement.id.to_s)
        @no_user_articles.each do |k, v|
          if k == @article.id.to_s
            @no_user_articles[k] += 1
          end
        end
      else
        @no_user_articles[params[:format]] = 1
      end


    end  ###################################################################################################################################

    if @complement.on_discount.nil? || @complement.on_discount == false || @complement.discount != 0
      if current_user == nil
        @items_cost += @complement.cost
      end

      if current_user != nil
          @shopping_cart.current_cost += @complement.cost
          @shopping_cart.save
      end

    else
      if current_user == nil
        @items_cost += (@complement.cost- (@complement.cost*@complement.discount/100))
      end
      @shopping_cart.current_cost += (@complement.cost- (@complement.cost*@complement.discount/100))
      @shopping_cart.save
    end

    redirect_to shopping_carts_show_path
  end


  def plus_no_user

    #if current_user == nil
    #  flash[:error] = "Morate biti ulogirani da bi stavljali artikle u kosaricu!"
    #  return redirect_to :back
    #end

    @no_articles = Article.where(id: @no_user_articles.keys)
    @sa = SingleArticle.where(id: @no_user_single_articles.keys)

    puts "uso plus _no user"


    art = SingleArticle.find_by(id: params[:format])

    if art.article.on_discount != nil && art.article.on_discount == true
      prize = (art.article.cost- (art.article.cost*art.article.discount/100))
    else
      prize = art.article.cost
    end



        puts "uso u has key?"
       @no_user_single_articles.each do |k, v|
         puts "uso u no user articles petlju"
         if k == art.id
           puts "uso u if provjeru"
          @no_user_single_articles[k] += 1
          @items_cost+=prize
         end
          end


    redirect_to :back
  end

  def min_no_user
    #if current_user == nil
    #  flash[:error] = "Morate biti ulogirani da bi stavljali artikle u kosaricu!"
    #  return redirect_to :back
    #end

    @articles = Article.where(id: @no_user_articles.keys)
    @sa = SingleArticle.where(id: @no_user_single_articles.keys)

    puts "uso plus _no user"

    art = SingleArticle.find_by(id: params[:format])

    if art.article.on_discount != nil && art.article.on_discount == true
      prize = (art.article.cost- (art.article.cost*art.article.discount/100))
    else
      prize = art.article.cost
    end

    #binding.pry

    puts "uso u has key?"
    @no_user_single_articles.each do |k, v|
      puts "uso u no user articles petlju"
      if k == art.id
        if v > 1
        puts "uso u if provjeru"
        @no_user_single_articles[k] -= 1
        @items_cost-=prize
        else
          @no_user_single_articles.delete(k)
          @items_cost-=prize
        end
      end
    end


    redirect_to :back

  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def cartsArticles_params
    params.require(:cartsArticles).permit(:id, :shopping_cart_id, :single_articles_id, :amount)
  end

  def set_anchor
    env["HTTP_REFERER"] += '#articles_end' unless env["HTTP_REFERER"].blank?
  end

  def set_article_session
    if current_user == nil
      session[:no_user_articles] = @no_user_articles
      session[:no_user_single_articles] = @no_user_single_articles
      session[:items_cost] = @items_cost
    end
  end
end
