class SendWelcomeMail < ApplicationMailer
 # include SuckerPunch::Job
  default from: 'no-reply@example.com'
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Puppify!")
  end
end
