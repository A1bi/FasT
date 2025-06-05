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

    def translate_log_event(event)
      options = {
        **event.info,
        scope: [:activerecord, :attributes, event.model_name.i18n_key, :actions,
                event.loggable.class.base_class.model_name.i18n_key]
      }
      t(event.action, **options)
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

    def order_pay_method(order)
      pay_method = order.stripe_payment? ? order.stripe_payment.method : order.pay_method
      t(pay_method, scope: 'ticketing.orders.pay_methods')
    end

    def order_retail_printable_path(order)
      retail_printable_api_ticketing_order_path(order.signed_id(expires_in: 1.hour))
    end

    def date_disabled?(date)
      date.cancelled? || (date.sold_out? && !current_user&.admin?)
    end

    def stripe_public_key
      Rails.application.credentials.stripe[Rails.env.production? ? 'live' : 'test'].public_key
    end

    private

    def translate_billing_transaction_note(key)
      Ticketing::Billing::Transaction.human_enum_name(:notes, key)
    end

    def sign_number(number, formatted_number)
      "#{'+' if number.positive?}#{formatted_number}"
    end
  end
end
