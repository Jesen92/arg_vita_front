class PurchasesController < ApplicationController
  #TODO napraviti da kod kupnje isto provjeri da li ima dovoljno artikla na skladistu
  require 'net/http'
  require "json"
  require 'paypal-sdk-rest'
  include PayPal::SDK::REST
  before_filter :set_user, :set_cart, :set_main_title

  def create
    #unless check_service_captcha(params["g-recaptcha-response"])
    #  flash[:recaptcha_error] = "<h3>Kupnja nije uspjela! Označite captcha-u!</h3>"
    #  return redirect_to :back
    #end #TODO odkomentiraj provjeru captcha-e; u html-u i js-u takodjer
    if @carts_article == nil
      flash[:error] = "Nemate ništa u košarici!"

      return redirect_to :back
    end
    session[:delivery_info_params] = delivery_info_params

    if params[:past_purchase][:payment_method].include? "Paypal"
      payment = paypal_payment
      return redirect_to @payment.links.find { |link| link.rel == 'approval_url' }.href unless payment.nil?

      flash[:error] = "Pogreška pri kupnji! Molimo kontaktirajte dućan ili pokušajte ponovo!"
    elsif  params[:past_purchase][:payment_method].include? "Credit card"
      flash[:notice] = "Kreditna kartica!"
    else
      SuccessfulPurchase.new(session[:delivery_info_params], current_user).succesful_payment
      flash[:notice] = "Uspješno se obavili kupnju! Dobiti ćete e-mail potvrdu!"
    end

    redirect_to :back
  end

  def create_no_user

  end

  def purchase_success
    payment = Payment.find(params[:paymentId])

    if payment.execute( payer_id: params[:PayerID] )
      # Success Message
      flash[:notice] = "Uspješno se obavili kupnju! Dobiti ćete e-mail potvrdu!"

      SuccessfulPurchase.new(session[:delivery_info_params], current_user).succesful_payment

      #UserMailer.checkout_mail(current_user).deliver_now #TODO odkomentiraj za slanje mail-a nakon kupnje
    else
      payment.error # Error Hash
      flash[:error] = "Greška kod obavljanja kupnje!"
    end

    redirect_to root_path
  end

  private

  def paypal_payment
    url = URI.parse('http://api.fixer.io/latest?symbols=HRK,EUR')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    currency_conversion_rate = JSON.parse(res.body)["rates"]["HRK"]

    item_params = []

    @user = current_user

    @shopping_cart = ShoppingCart.find_by(user_id: current_user.id)
    @carts_article = CartsArticle.where(shopping_cart_id: @shopping_cart.id)

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
                                                         :total => (@shopping_cart.current_cost/currency_conversion_rate).round(2).to_s,
                                                         :currency => "EUR"},
                                                     :description => "Argentum Vita Nakit"}]})

    #TODO ukupna cijena bi se ovdje trebala postavljat na nulu
    @current_purchase_sum = 0

    @carts_article.each do |art|

      if art.article != nil

        item_params << {:name => art.article.title, :sku => art.article.code, :price => (art.cost/currency_conversion_rate).round(2).to_s, :currency => 'EUR', :quantity => art.amount}

      elsif art.single_article != nil

        item_params << {:name => art.single_article.title, :sku => art.single_article.code, :price => (art.cost/currency_conversion_rate).round(2).to_s, :currency => 'EUR', :quantity => art.amount}

      end

    end

    #flash[:notice] = "Uspješno ste obavili kupnju! Dobiti ćete email sa konfirmacijom kupnje!"
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
    params.require(:past_purchase).permit(:email, :country, :postal_code, :city, :address, :phone_num, :remark, :payment_method)
  end

  def check_service_captcha(recaptcha_param)
    verify_recaptcha(response: recaptcha_param)
  end
end
