class UserMailer < ApplicationMailer
  default from: "no-reply@argentumvita.com"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Puppify!")
  end

  def checkout_mail(user, params={})
    @user = user
    @shopping_cart = ShoppingCart.find_by(user_id: user.id)
    @delivery_info = params

    mail(to: user.email, bcc: 'info@argentumvita.com', subject: "Argentum Vita d.o.o. - Kupnja "+DateTime.now.strftime("%d.%m.%Y. - %H:%M"), template_path: 'user_mailer', template_name: 'checkout_mail')
  end

  def contact_us_mail(params)
    @email = params[:email]
    @name = params[:name]
    @subject = params[:subject]
    @message = params[:message]

    mail(to: 'info@argentumvita.hr', bcc: 'info@argentumvita.com', subject: "Argentum Vita d.o.o. - Upit "+DateTime.now.strftime("%d.%m.%Y. - %H:%M"), template_path: 'user_mailer', template_name: 'contact_us_mail')
  end
end
