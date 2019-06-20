return json.errors @order.errors.messages unless @order.persisted?

json.call(@order, :id, :number, :total)
json.call(@order, :printable_path) if retail?

json.tickets @order.tickets, :id, :number, :price
