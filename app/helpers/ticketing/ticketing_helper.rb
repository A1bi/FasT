# frozen_string_literal: true

module Ticketing
  module TicketingHelper
    def format_billing_amount(amount)
      (amount.positive? ? '+' : '') + number_to_currency(amount)
    end

    def event_logo(event, image_options: {}, fallback_tag: :h2,
                   fallback_options: {})
      path = "theater/#{event.assets_identifier}/ticket_header.svg"
      return image_tag path, image_options if asset_exists? path

      content_tag fallback_tag, event.name, fallback_options
    end

    def translate_log_event(event)
      options = event.info.dup
      options[:scope] = [:activerecord, :attributes,
                         event.model_name.i18n_key, :actions,
                         event.loggable.class.base_class.model_name.i18n_key]
      t(event.action, options)
    end
  end
end
