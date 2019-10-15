json.signing_keys @signing_keys, :id, :secret

json.dates @dates, :id, :date

json.seats @seats, :id, :block_id

json.blocks @blocks, :id, :entrance

json.ticket_types @ticket_types, :id, :name

json.changed_tickets @changed_tickets,
                     :id, :date_id, :number, :type_id, :seat_id, :cancelled?
