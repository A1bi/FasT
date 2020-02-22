# frozen_string_literal: true

json.ticket_id @ticket&.id.to_s

json.orders @orders, partial: 'order', as: :order
