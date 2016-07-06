require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

CONFIG = YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))
CONFIG.merge!(CONFIG.fetch(Rails.env, {}))
CONFIG.deep_symbolize_keys!

module FasT
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = ""

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql
    config.active_record.raise_in_transactional_callbacks = true
    
    config.action_controller.include_all_helpers = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.assets.paths << Rails.root.join("lib", "assets", "javascripts")
    
    config.to_prepare do
      Passbook.options[:path] = File.join("system", "passbook")
      Passbook.options[:full_path] = File.join(Rails.public_path, Passbook.options[:path])
    end
    
    config.secret_key_base = CONFIG[:secret_token]
    config.action_mailer.default_url_options = CONFIG[:url_options]
    config.roadie.url_options = CONFIG[:url_options]
    Rails.application.routes.default_url_options = CONFIG[:url_options]
    
    Paperclip.options[:command_path] = CONFIG[:imagemagick_path]
  end
end
