require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  require 'database_cleaner'
  require 'authlogic/test_case'

  include Authlogic::TestCase

  RSpec.configure do |config|
    config.include MailerMacros
    config.include FactoryGirl::Syntax::Methods

    config.mock_with :rspec
    config.render_views

    config.before(:each) do
      activate_authlogic
      reset_email
    end

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
  DatabaseCleaner.clean
end
