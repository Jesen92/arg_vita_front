class UserMailer < ApplicationMailer
  default from: "NO REPLY - Argentum Vita d.o.o. <no-reply@mail.com>"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Argentum Vita d.o.o.!")
  end

  def checkout_mail(user, params={})
    @user = user
    @shopping_cart = ShoppingCart.find_by(user_id: user.id)
    @delivery_info = params
    @coupon = Coupon.find_by(id: params[:coupon_id] ) if params[:coupon_id].present?
    @email = @user.email.gsub(',', '.')

    mail(to: [@email, 'info@argentumvita.com'], bcc: 'hrvoje.jesenovic@cactus-code.com', subject: "Narudzba #"+@delivery_info[:purchase_id].to_s+" - Argentum Vita d.o.o. - "+DateTime.now.strftime("%d.%m.%Y. - %H:%M"), template_path: 'user_mailer', template_name: 'checkout_mail')
  end

  def contact_us_mail(params)
    @email = params[:email]
    @name = params[:name]
    @subject = params[:subject]
    @message = params[:message]

    mail(to: [@email, 'info@argentumvita.com'], subject: "Argentum Vita d.o.o. - Upit "+DateTime.now.strftime("%d.%m.%Y. - %H:%M"), template_path: 'user_mailer', template_name: 'contact_us_mail')
  end
end
