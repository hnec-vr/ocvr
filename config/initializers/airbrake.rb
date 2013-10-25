Airbrake.configure { |config| config.api_key = ENV['AIRBRAKE_API_KEY'] } if Rails.env.production?
