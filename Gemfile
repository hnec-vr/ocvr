source 'http://rubygems.org'

ruby "1.9.3"

gem 'rails', '3.2.14'
gem 'jquery-rails'
gem 'haml-rails'
gem 'dynamic_form'
gem 'nested_form'
gem 'authlogic'
gem 'simple_captcha', :git => 'git://github.com/galetahub/simple-captcha.git'
gem 'i18n-country-translations'
gem 'rails-i18n', '~> 3.0.0'
gem 'delayed_job_active_record'

group :production do
  gem 'mysql2'
end

group :development, :test do
  gem 'pg'
  gem 'rspec-rails'
  gem 'spork-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
end

group :assets do
  gem 'uglifier'
  gem 'sass-rails'
end
