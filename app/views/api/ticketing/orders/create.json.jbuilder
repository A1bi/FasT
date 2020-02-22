# frozen_string_literal: true

json.call(@order, :id, :number, :total)
json.call(@order, :printable_path) if @order.is_a? Ticketing::Retail::Order

json.tickets @order.tickets, :id, :number, :price
