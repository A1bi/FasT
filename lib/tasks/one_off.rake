# frozen_string_literal: true

namespace :one_off do
  task run: :environment do
    orders = Ticketing::Web::Order
             .joins(:tickets)
             .where(ticketing_tickets:
               {
                 date_id: Ticketing::EventDate.cancelled(true),
                 cancellation_id: nil
               })
             .distinct

    orders.each do |order|
      Ticketing::RefundMailer.with(order: order).notification.deliver_later
    end
  end
end
