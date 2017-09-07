PayPal::SDK.load("config/paypal.yml", ENV['RACK_ENV'] || 'development')
PayPal::SDK.logger = Rails.logger

PayPal::SDK::REST.set_config(
    :mode => "sandbox", # "sandbox" or "live"
    :client_id => ENV['PAYPAL_CLIENT_ID'],
    :client_secret => ENV['PAYPAL_SECRET'])
