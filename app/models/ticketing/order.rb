module Ticketing
  class Order < BaseModel
  	include Loggable, Cancellable, RandomUniqueAttribute
	
  	has_many :tickets, after_add: :added_ticket, dependent: :destroy
    has_random_unique_number :number, 6
    belongs_to :coupon, touch: true
	
  	validates_length_of :tickets, minimum: 1
    
    before_create :before_create
    after_create :after_create
    
    def total
      self[:total] || 0
    end
    
    def printable_path(full = false)
      File.join(tickets_dir_path(full), "tickets-" + Digest::SHA1.hexdigest(number.to_s) + ".pdf")
    end
    
    def self.api_hash
      includes({ tickets: [:seat, :date] }).all.map { |order| order.api_hash }
    end
    
    def api_hash(detailed = false)
      {
        id: id.to_s,
        number: number.to_s,
        total: total,
        paid: paid || false,
        created: created_at.to_i,
        tickets: tickets.map do |ticket|
          info = { id: ticket.id.to_s, number: ticket.number.to_s, dateId: ticket.date.id.to_s, typeId: ticket.type_id.to_s, price: ticket.price, seatId: ticket.seat.id.to_s }
          info[:can_check_in] = ticket.can_check_in? if detailed
          info
        end,
        printable_path: printable_path
      }
    end
    
    def mark_as_paid
      return if paid
    
      self.paid = true
      save
      
      log(:marked_as_paid, nil)
    end
    
    private
    
    def added_ticket(ticket)
      self[:total] = ticket.type.price.to_f + total.to_f
    end
    
    def after_create
      log(:created)
      create_printable
    end
    
    def before_create
      self.paid = true if total.zero?
    end
    
    def tickets_dir_path(full = false)
      path = Rails.public_path if full
      File.join(path || "", "/system/tickets")
    end
    
    def create_printable
      FileUtils.mkdir_p(tickets_dir_path(true))
      
      pdf = TicketsPDF.new(true)
      pdf.add_order self
      pdf.render_file(printable_path(true))
    end
  end
end