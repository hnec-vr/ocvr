require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module OCVR
  class Application < Rails::Application
    config_file_path = Rails.root.join('config', 'settings.yml')
    if File.exist?(config_file_path)
      ::SETTINGS = YAML.load_file(config_file_path)[Rails.env]
    else
      raise "WARNING: configuration file #{config_file_path} not found."
    end

    config.autoload_paths += %W(#{config.root}/lib)

    config.time_zone = 'Central Time (US & Canada)'

    config.i18n.default_locale = :ar

    config.i18n.fallbacks = [:en]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.initialize_on_precompile = false

    config.assets.precompile += ['application.css', 'application.js', 'admin.css', 'admin.js']

    config.filter_parameters += [:password, :password_confirmation]

    config.action_mailer.default_url_options = {:host => ::SETTINGS[:default_host]}
  end

  require 'trimmer'
  class ActiveRecord::Base
    include Trimmer
  end
end
