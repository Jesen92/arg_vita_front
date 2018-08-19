class HomeController < ApplicationController
  before_filter :set_user, :set_cart, :set_main_title

  def index
    add_breadcrumb "Home", :root_path

    @articles = Article.where(raw: false, for_sale: true).order('created_at DESC').first(8)

    discount_params = {current_user: user_signed_in? ? current_user : nil, shopping_cart_sum: user_signed_in? ? @shopping_cart.current_cost : @items_cost}
    p = Proc.new {|article| discount_params[:article_discount] = article.on_discount? ? article.discount : 0; article.discount = get_discount(discount_params); article }
    gon.current_min, gon.current_max = 0

    @articles.collect!(&p)
  end

  def general
    if user_signed_in?
      @cart = ShoppingCart.where(user_id: current_user.id)
    end

  end

  def download_pdf
    send_file(
        "#{Rails.root}/public/assets/Obrazac-za-jednostrani-raskid-ugovora_1.pdf",
        filename: "Obrazac za jednostrani raskid ugovora.pdf",
        type: "application/pdf"
    )
  end

  def contact_page
  end

  def about_us_page
  end

  def payment_methods

  end

  def contact_us
    unless check_service_captcha(params["g-recaptcha-response"])
      flash[:recaptcha_error] = "Označite captcha-u!"
      return redirect_to about_us_page_path(anchor: 'CONTACT')
    end

    if params[:email_form][:name].blank? || params[:email_form][:email].blank? || params[:email_form][:subject].blank? || params[:email_form][:message].blank?
      flash[:recaptcha_error] = "Molimo ispunite sva polja prije slanja upita!"
      return redirect_to about_us_page_path(anchor: 'CONTACT')
    end

    UserMailer.contact_us_mail(params[:email_form]).deliver_now
    flash[:notice] = "Zahvaljujemo na vašem upitu!"
    redirect_to :back
  end

  private

  def check_service_captcha(recaptcha_param)
    verify_recaptcha(response: recaptcha_param)
  end

end
