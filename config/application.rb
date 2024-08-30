# frozen_string_literal: true

require_relative 'boot'

require 'rails'

require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'action_cable/engine'
# require 'action_mailbox/engine'
# require 'action_text/engine'
# require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module FasT
  class Application < Rails::Application
    config.autoload_lib(ignore: %w[capistrano tasks])

    # Activate observers that should always be running.
    # config.active_record.observers = ""

    config.time_zone = 'Europe/Berlin'

    config.i18n.default_locale = :de

    config.encoding = 'utf-8'

    config.load_defaults 7.2

    config.action_dispatch.rescue_responses.merge!(
      'ActiveSupport::MessageVerifier::InvalidSignature' => :forbidden
    )

    config.active_support.escape_html_entities_in_json = true

    config.active_support.halt_callback_chains_on_return_false = false

    config.active_record.schema_format = :sql
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess]

    config.action_controller.include_all_helpers = false

    # since Rails 7.1 overwriting the following in test.rb does not work for some reason
    config.require_master_key = !Rails.env.test?

    config.active_job.queue_adapter = :sidekiq

    url_options = Settings.url_options.to_h
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = Settings.smtp.to_h
    config.action_mailer.default_options = Settings.action_mailer.defaults
    config.action_mailer.default_url_options = url_options
    config.roadie.url_options = url_options
    Rails.application.routes.default_url_options = url_options

    Paperclip.options[:command_path] = Settings.imagemagick_path

    config.hosts.clear
  end
end
