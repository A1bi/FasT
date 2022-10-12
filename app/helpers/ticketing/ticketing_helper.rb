# frozen_string_literal: true

module Ticketing
  module TicketingHelper
    def format_billing_amount(amount)
      sign_number(amount, number_to_currency(amount))
    end

    def format_free_tickets_count(count, signed: false)
      formatted_count = "#{count.to_i} " +
                        t('ticketing.coupons.free_ticket', count: count.abs)
      signed ? sign_number(count, formatted_count) : formatted_count
    end

    def coupon_value(coupon, initial: false)
      value = initial ? coupon.initial_value : coupon.value
      if coupon.free_tickets_value?
        format_free_tickets_count(value)
      else
        number_to_currency(value)
      end
    end

    def event_logo(event, image_options: {}, fallback_tag: :h2,
                   fallback_options: {})
      path = "theater/#{event.assets_identifier}/title.svg"
      return image_tag path, image_options if asset_exists? path

      content_tag fallback_tag, event.name, fallback_options
    end

    def translate_log_event(event)
      additional_info = event.info.except(:count)
      action = if additional_info.any? && additional_info.values.first.blank?
                 "#{event.action}_no_#{additional_info.keys.first}"
               else
                 event.action
               end
      options = event.info.dup
      options[:scope] = [:activerecord, :attributes,
                         event.model_name.i18n_key, :actions,
                         event.loggable.class.base_class.model_name.i18n_key]
      t(action, **options)
    end

    def translate_billing_transaction(transaction)
      translate_billing_transaction_note(transaction.note_key)
    end

    def billing_action_options(actions)
      options = actions.map do |action|
        [translate_billing_transaction_note(action), action]
      end
      options_for_select(options)
    end

    private

    def translate_billing_transaction_note(key)
      Ticketing::Billing::Transaction.human_enum_name(:notes, key)
    end

    def sign_number(number, formatted_number)
      "#{number.positive? ? '+' : ''}#{formatted_number}"
    end
  end
end
