module Ticketing
  module Orderable
  	extend ActiveSupport::Concern
	
  	included do
      has_one :bunch, :as => :assignable, :validate => true
    
      validates_presence_of :bunch
      
      def api_hash
        {
          id: id,
          number: "123456", # bunch.number
          total: bunch.total,
          tickets: bunch.tickets.map do |ticket|
            { id: ticket.id, number: "654321", dateId: ticket.date.id, typeId: ticket.type_id, price: ticket.price, seatId: ticket.seat.id }
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