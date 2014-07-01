module Ticketing
  class Retail::Order < Order
    belongs_to :store
  
    validates_presence_of :store
    
    before_create :before_create
    after_destroy :delete_printable
    
    def self.by_store(retail_id)
      where(:store_id => retail_id)
    end
    
    def printable_path(full = false)
      File.join(printable_dir_path(full), "tickets-" + Digest::SHA1.hexdigest(number.to_s) + ".pdf")
    end
    
    def updated_tickets(t = nil)
      update_printable
    end
    
    def api_hash(detailed = false)
      super.merge({
        printable_path: printable_path
      })
    end
    
    private
    
    def before_create
      mark_as_paid(false)
    end
    
    def printable_dir_path(full = false)
      path = Rails.public_path if full
      File.join(path || "", "/system/tickets")
    end
    
    def update_printable
      FileUtils.mkdir_p(printable_dir_path(true))
      
      pdf = TicketsPDF.new(true)
      pdf.add_order self
      pdf.render_file(printable_path(true))
    end
    
    def delete_printable
      FileUtils.rm(printable_path(true))
    end
  end
end