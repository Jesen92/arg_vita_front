
Rails.application.configure do

  ActionMailer::Base.smtp_settings = {
      :address   => 'smtp.mandrillapp.com',
      :port      => '587',
      :enable_starttls_auto => true,
      :user_name => 'filipkapusta1@gmail.com',
      :password  => 'ShBeRdRK9HnK0ztxJbWUKQ',
      :authentication => :plain,
      :domain => 'gmail.com'
  }

  ActionMailer::Base.delivery_method = :smtp
end