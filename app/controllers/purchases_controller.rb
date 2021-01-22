class PurchasesController < ApplicationController
  #TODO napraviti da kod kupnje isto provjeri da li ima dovoljno artikla na skladistu
  require 'net/http'
  require "json"
  require 'paypal-sdk-rest'
  require 'digest'
  include PayPal::SDK::REST
  include ActionView::Helpers::NumberHelper
  include HTTParty
  before_filter :set_user, :set_cart, :set_main_title
  skip_before_action :verify_authenticity_token, only: [:purchase_success_credit_card]

  def create
    #unless check_service_captcha(params["g-recaptcha-response"])
    #  flash[:recaptcha_error] = "<h3>Kupnja nije uspjela! Označite captcha-u!</h3>"
    #  return redirect_to :back
    #end #TODO odkomentiraj provjeru captcha-e; u html-u i js-u takodjer
    if @carts_article == nil
      flash[:error] = "Košarica je prazna!"

      return redirect_to :back
    end
    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @shopping_cart.delivery_info_params = delivery_info_params.to_json
    @shopping_cart.save
    session[:delivery_info_params] = delivery_info_params.to_json

    if params[:users_purchase][:payment_method].blank?
      flash[:error] = "Molimo odaberite način plaćanja prije izvršavanja kupnje!"
      return redirect_to :shopping_carts_show
    end


    if params[:users_purchase][:payment_method].include? "Paypal"
      payment = paypal_payment
      return redirect_to @payment.links.find { |link| link.rel == 'approval_url' }.href unless payment.nil?

      flash[:error] = "Pogreška pri kupnji! Molimo kontaktirajte dućan ili pokušajte ponovo!"
    elsif  params[:users_purchase][:payment_method].include? "Credit card"
      @credit_card_params = CreditCardParam.new(credit_card_payment)
      @delivery_info = delivery_info_params

      return render :create
    elsif params[:users_purchase][:payment_method].downcase.include? "virman"
      SuccessfulPurchase.new(JSON.parse(session[:delivery_info_params]), current_user, 23).succesful_payment
      flash[:purchase] = "Uspješno se obavili kupnju! Na email ćete dobiti virman sa informacijama za uplatu!"
      return redirect_to root_path
    else
      SuccessfulPurchase.new(JSON.parse(session[:delivery_info_params]), current_user, 23).succesful_payment
      flash[:purchase] = "Uspješno se obavili kupnju! Dobiti ćete e-mail potvrdu!"
      return redirect_to root_path
    end

    redirect_to :back
  end

  def create_no_user

  end

  def purchase_success
    payment = Payment.find(params[:paymentId])

    if payment.execute( payer_id: params[:PayerID] )
      # Success Message
      flash[:purchase] = "Uspješno se obavili kupnju! Dobiti ćete e-mail potvrdu!"

      SuccessfulPurchase.new(JSON.parse(session[:delivery_info_params]), current_user, 23).succesful_payment

      #UserMailer.checkout_mail(current_user).deliver_now #TODO odkomentiraj za slanje mail-a nakon kupnje
    else
      payment.error # Error Hash
      flash[:error] = "Greška kod obavljanja kupnje!"
    end

    redirect_to root_path
  end

  def purchase_success_credit_card
    if params[:success] == 'true'
      flash[:purchase] = "Uspješno se obavili kupnju! Dobiti ćete e-mail potvrdu!"

      shopping_cart = ShoppingCart.find_by(last_order_number: params[:order_number])
      user = shopping_cart.user

      SuccessfulPurchase.new(JSON.parse(shopping_cart.delivery_info_params), user, 23, params[:approval_code]).succesful_payment
    else
      flash[:error] = "Greška kod obavljanja kupnje!"
    end

    redirect_to root_path
  end

  private

  def credit_card_payment
    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.where(shopping_cart_id: @shopping_cart.id)
    coupon = Coupon.find_by(id: delivery_info_params[:coupon_id] ) if delivery_info_params[:coupon_id].present?

    order_number = (0...21).map { (65 + rand(20)).chr }.join
    session[:order_number] = order_number
    @shopping_cart.last_order_number = order_number
    @shopping_cart.save

    #session[:order_number] = "order_"+(PastPurchase.last.id+1).to_s
    shipping_cost = @shopping_cart.current_cost >= 100 ? 0 : 23
    sha1_hash = Digest::SHA1.hexdigest ENV['CORVUS_SECRET']+":"+session[:order_number]+":"+number_to_currency(@shopping_cart.current_cost+shipping_cost, unit: "", separator: ".", delimiter: "")+":HRK"

    cart = @carts_article.map {|cart|
      if !cart.article.nil?
        cart.amount.to_s+'x'+cart.article.code.upcase
      else
        cart.amount.to_s+'x'+cart.single_article.code.upcase
      end
    }.join(" ")

    amount = @shopping_cart.current_cost+shipping_cost
    if coupon.present?
      amount = amount-(amount*(coupon.discount/100.00))
    end
    
    credit_card_params = {
        :target => '_top',
        :mode => 'form',
        :store_id => ENV['CORVUS_STORE_ID'].to_i,
        :order_number => order_number,
        :language => 'hr',
        :currency => 'HRK',
        :amount => number_to_currency(amount, unit: "", separator: ".", delimiter: ""),
        :cart => cart,
        :required_hash => sha1_hash,
        :require_complete => "true"
    }

=begin
    _url = "target=_top&mode=form&store_id=101&order_number=1233&language=hr&currency=H
    RK&amount=123.54&cart=2xLCDTV&hash=6cb317d8b6ade738cb9dc02cae220b3bd2b4bc82
    &require_complete=false"
=end

    #credit_card_params.map {|key, value| key.to_s+"="+value.to_s }.join("&")
    credit_card_params
  end

  def paypal_payment
    url = URI.parse('http://api.fixer.io/latest?symbols=HRK,EUR')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    currency_conversion_rate = JSON.parse(res.body)["rates"]["HRK"]

    item_params = []

    @user = current_user
    @ukupno_euro = 0.00
    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.where(shopping_cart_id: @shopping_cart.id)

    #TODO ukupna cijena bi se ovdje trebala postavljat na nulu
    #TODO shipping se mora dodati (23 kn)
    @current_purchase_sum = 0

    @carts_article.each do |art|

      if art.article != nil
        @ukupno_euro += (art.cost/currency_conversion_rate).round(2)
        item_params << {:name => art.article.title, :sku => art.article.code, :price => (art.cost/currency_conversion_rate).round(2).to_s, :currency => 'EUR', :quantity => art.amount}
        #binding.pry
      elsif art.single_article != nil
        @ukupno_euro += (art.cost/currency_conversion_rate).round(2)
        item_params << {:name => art.single_article.title, :sku => art.single_article.code, :price => (art.cost/currency_conversion_rate).round(2).to_s, :currency => 'EUR', :quantity => art.amount}
        #binding.pry
      end

    end

    #flash[:notice] = "Uspješno ste obavili kupnju! Dobiti ćete email sa konfirmacijom kupnje!"
    @payment = Payment.new({
                               :intent => "sale",
                               :payer => {
                                   :payment_method => "paypal"},
                               :redirect_urls => {
                                   :return_url => "http://localhost:3000/purchases/purchase_success",
                                   :cancel_url => "http://localhost:3000/"},
                               :transactions => [{
                                                     :item_list => {
                                                         :items => []},
                                                     :amount => {
                                                         :total => @ukupno_euro.to_s,
                                                         :currency => "EUR"},
                                                     :description => "Argentum Vita Nakit"}]})

    item_params.each do |item|
      @payment.transactions.first.item_list.items << item
    end
    
    if @payment.create
      @payment

    else
      @payment.error  # Error Hash
      nil
    end
  end

  def extract_link(data)
    data.links.find { |link| link.rel == 'approval_url' }.href
  end

  def delivery_info_params
    params.require(:users_purchase).permit(:coupon_id, :email, :country, :postal_code, :city, :address, :phone_num, :remark, :payment_method)
  end

  def check_service_captcha(recaptcha_param)
    verify_recaptcha(response: recaptcha_param)
  end

  def secure_path_for(params, *excluded_params)
    url_for(params.except(*excluded_params).merge(only_path: true))
  end
end
