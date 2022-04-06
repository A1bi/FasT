# frozen_string_literal: true

module OrdersHelper
  def structured_data(order)
    tag.script type: 'application/ld+json' do
      raw render(partial: 'orders/structured_data', formats: :json, locals: { order: }) # rubocop:disable Rails/OutputSafety
    end
  end

  def reservation_status(ticket)
    schema_prefixed(ticket.cancelled? ? 'ReservationCancelled' : 'ReservationConfirmed')
  end

  def order_url(order)
    order_overview_url(order.signed_info(authenticated: true))
  end

  def schema_prefixed(entity)
    "#{schema_context}/#{entity}"
  end

  def schema_context
    'http://schema.org'
  end
end
