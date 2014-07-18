module Ticketing
  class Order < BaseModel
  	include Loggable, Cancellable, RandomUniqueAttribute
	
  	has_many :tickets, dependent: :destroy, autosave: true
    has_random_unique_number :number, 6
    belongs_to :coupon, touch: true
	
  	validates_length_of :tickets, minimum: 1
    
    before_validation :before_validation
    before_create :before_create
    after_create :after_create
    
    def total
      self[:total] || 0
    end
    
    def number
      "1#{self[:number]}"
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
        tickets: tickets.map { |ticket| ticket.api_hash }
      }.merge(super())
    end
    
    def mark_as_paid(save = true)
      return if paid
    
      self.paid = true
      mark_tickets_as_paid(tickets)
      self.save if save
      
      log(:marked_as_paid)
    end
    
    def cancel(reason)
      super
      tickets.each do |ticket|
        ticket.cancel(cancellation)
      end
      cancel_payment
      update_total
      updated_tickets
      save
      log(:cancelled)
    end
    
    def cancel_tickets(tickets, reason)
      if tickets.count == self.tickets.count
        cancel(reason)
      else
        cancellation = nil
        tickets.each do |ticket|
          ticket.cancel(cancellation || reason)
          cancellation = ticket.cancellation if cancellation.nil?
        end
        if cancellation && self.tickets.cancelled(false).count.zero?
          self.cancellation = cancellation
          cancel_payment
        end
        update_total
        updated_tickets(tickets)
        save
        log(:tickets_cancelled, { count: tickets.count, reason: reason })
      end
    end
    
    def mark_tickets_as_paid(t = nil)
      (t || tickets).each do |ticket|
        ticket.paid = true
      end
    end
    
    def updated_tickets(t = nil)
    end
    
    private
    
    def after_create
      log(:created)
      updated_tickets
    end
    
    def before_validation
      update_total
    end
    
    def before_create
      mark_as_paid(false) if total.zero?
    end
    
    def update_total
      self.total = 0
      tickets.each do |ticket|
        self.total = total.to_f + ticket.price.to_f if !ticket.cancelled?
      end
    end
    
    def cancel_payment
      self.pay_method = nil
    end
  end
end