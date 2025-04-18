# frozen_string_literal: true

json.call(@order, :id, :number, :total)
json.printable_path order_retail_printable_path(@order) if @order.is_a? Ticketing::Retail::Order

json.tickets @order.tickets, :id, :number, :price
