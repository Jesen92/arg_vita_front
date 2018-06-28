Rails.application.configure do
  require 'active_merchant'
  # Settings specified here will take precedence over those in config/application.rb.
  config.after_initialize do
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  end

  config.action_mailer.asset_host = "http://localhost:3000"
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }

# paypal ################################################################################
  config.gem "activemerchant", :lib => "active_merchant", :version => "1.56.0"
=begin
  PayPal::SDK::REST.set_config(
      :mode => "sandbox", # "sandbox" or "live"
      :client_id => ENV['PAYPAL_CLIENT_ID'],
      :client_secret => ENV['PAYPAL_SECRET'])
=end
  #test

########################################################################################

  config.paperclip_defaults = {
      :storage => :s3,
      :s3_host_name => "s3.eu-central-1.amazonaws.com",
      :s3_credentials => {
          :bucket => ENV['STOR'],
          :access_key_id => ENV['ACC_ID'],
          :secret_access_key => ENV['SEC']
      }
  }


  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true


end
