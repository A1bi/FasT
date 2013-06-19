module Ticketing
  class Bunch < ActiveRecord::Base
  	include Cancellable, RandomUniqueAttribute
	
  	has_many :tickets, :after_add => :added_ticket
  	belongs_to :assignable, :polymorphic => true, :touch => true
    has_random_unique_number :number, 6
	
  	validates_length_of :tickets, :minimum => 1
    
    after_create :create_printable
	
    def added_ticket(ticket)
      self[:total] = ticket.type.price.to_f + total.to_f
    end
    
    def printable_path(full = false)
      File.join(tickets_dir_path(full), "tickets-" + Digest::SHA1.hexdigest(number.to_s) + ".pdf")
    end
    
    private
    
    def tickets_dir_path(full = false)
      path = Rails.public_path if full
      File.join(path || "", "/system/tickets")
    end
    
    def create_printable
      FileUtils.mkdir_p(tickets_dir_path(true))
      
      pdf = TicketsPDF.new(true)
      pdf.add_bunch self
      pdf.render_file(printable_path(true))
    end
  end
end
