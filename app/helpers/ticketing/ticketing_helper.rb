module Ticketing
  module TicketingHelper
    def obfuscated_iban(iban)
      iban[0..1] + "X" * (iban.length - 5) + iban[-3..-1]
    end

    def format_billing_amount(amount)
      (amount > 0 ? "+" : "") + number_to_currency(amount)
    end

    def event_logo(event, image_options: {}, fallback_tag: :h2, fallback_options: {})
      path = "theater/#{event.identifier}/ticket_header.svg"
      return content_tag fallback_tag, event.name, fallback_options unless asset_exists? path
      image_tag path, image_options
    end
  end
end
