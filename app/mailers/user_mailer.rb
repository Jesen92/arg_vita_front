class UserMailer < ApplicationMailer
  default from: "neki@mail.com"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Puppify!")
  end

  def checkout_mail(user, params={})
    @user = user
    @shopping_cart = ShoppingCart.find_by(user_id: user.id)

    mail(to: user.email, subject: "Argentum Vita d.o.o. - Kupnja "+DateTime.now.strftime("%d.%m.%Y. - %H:%M"), template_path: 'user_mailer', template_name: 'checkout_mail')
  end
end
