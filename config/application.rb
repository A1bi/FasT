require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module FasT
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths << Rails.root.join('lib')

    # Activate observers that should always be running.
    # config.active_record.observers = ""

    config.time_zone = 'Berlin'

    config.i18n.default_locale = :de

    config.encoding = 'utf-8'

    config.load_defaults 6.0

    config.active_support.escape_html_entities_in_json = true

    config.active_support.halt_callback_chains_on_return_false = false

    config.active_record.schema_format = :sql

    config.action_controller.include_all_helpers = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('lib', 'assets', 'javascripts')

    config.require_master_key = true

    config.active_job.queue_adapter = :sidekiq

    url_options = Settings.url_options.to_h
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = Rails.application.credentials.smtp
    config.action_mailer.default_options = Settings.action_mailer.defaults
    config.action_mailer.default_url_options = url_options
    config.roadie.url_options = url_options
    Rails.application.routes.default_url_options = url_options

    Paperclip.options[:command_path] = Settings.imagemagick_path

    config.active_storage.service = :local
  end
end
