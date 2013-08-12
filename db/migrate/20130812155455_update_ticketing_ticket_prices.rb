class UpdateTicketingTicketPrices < ActiveRecord::Migration
  def up
    ActiveRecord::Base.record_timestamps = false
    Ticketing::Ticket.where(price: nil).includes(:type).each do |ticket|
      ticket.price = ticket.type.price
      ticket.save
    end
    ActiveRecord::Base.record_timestamps = true
  end
end
