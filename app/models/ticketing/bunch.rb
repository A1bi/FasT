module Ticketing
  class Bunch < ActiveRecord::Base
  	include Loggable, Cancellable, RandomUniqueAttribute
	
  	has_many :tickets, :after_add => :added_ticket, :dependent => :destroy
  	belongs_to :assignable, :polymorphic => true, :touch => true
    has_random_unique_number :number, 6
    belongs_to :coupon
	
  	validates_length_of :tickets, :minimum => 1
    
    before_create :before_create
    after_create :after_create
    
    def total
      self[:total] || 0
    end
    
    def printable_path(full = false)
      File.join(tickets_dir_path(full), "tickets-" + Digest::SHA1.hexdigest(number.to_s) + ".pdf")
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
      pdf.add_bunch self
      pdf.render_file(printable_path(true))
    end
  end
end
