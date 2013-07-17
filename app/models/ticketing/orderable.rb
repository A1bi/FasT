module Ticketing
  module Orderable
  	extend ActiveSupport::Concern
	
  	included do
      has_one :bunch, :as => :assignable, :validate => true, :dependent => :destroy
    
      validates_presence_of :bunch
      
      def api_hash
        hash = {
          id: id.to_s,
          number: bunch.number.to_s,
          total: bunch.total,
          paid: bunch.paid || false,
          created: created_at.to_i,
          tickets: bunch.tickets.map do |ticket|
            { id: ticket.id.to_s, number: ticket.number.to_s, dateId: ticket.date.id.to_s, typeId: ticket.type_id.to_s, price: ticket.price, seatId: ticket.seat.id.to_s }
          end,
          printable_path: bunch.printable_path
        }
        hash[:queue_number] = queue_number.to_s if self.is_a? Ticketing::Retail::Order
        hash
      end
      
      def mark_as_paid
        return if bunch.paid
      
        bunch.paid = true
        self[:queue_number] = nil if self.is_a? Ticketing::Retail::Order
        bunch.save
        save
        
        bunch.log(:marked_as_paid, nil)
        
        OrderMailer.payment_received(self).deliver if self.is_a? Ticketing::Web::Order
      end
  	end
    
    module ClassMethods
      def api_hash
        includes({ :bunch => { :tickets => [:seat, :date] } }).all.map { |order| order.api_hash }
      end
    end
  end
end