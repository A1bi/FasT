module Ticketing
  module Orderable
  	extend ActiveSupport::Concern
	
  	included do
      has_one :bunch, :as => :assignable, :validate => true
    
      validates_presence_of :bunch
      
      def api_hash
        {
          id: id.to_s,
          number: "123456", # bunch.number
          queue_number: "42",
          total: bunch.total,
          paid: bunch.paid || false,
          created: created_at.to_i,
          tickets: bunch.tickets.map do |ticket|
            { id: ticket.id.to_s, number: "654321", dateId: ticket.date.id.to_s, typeId: ticket.type_id.to_s, price: ticket.price, seatId: ticket.seat.id.to_s }
          end
        }
      end
  	end
    
    module ClassMethods
      def api_hash
        includes({ :bunch => { :tickets => [:seat, :date] } }).all.map { |order| order.api_hash }
      end
    end
  end
end