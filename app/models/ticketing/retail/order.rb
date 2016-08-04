module Ticketing
  class Retail::Order < Order
    belongs_to :store

    validates_presence_of :store

    before_save :check_tickets
    after_save :check_printable
    after_commit :delete_printable, on: :destroy

    def self.by_store(retail_id)
      where(:store_id => retail_id)
    end

    def printable_path(full = false)
      File.join(printable_dir_path(full), "tickets-" + Digest::SHA1.hexdigest(number.to_s) + ".pdf")
    end

    def api_hash(details = [], ticket_details = [])
      hash = super
      hash.merge!({
        printable_path: printable_path
      }) if details.include? :printable
      hash
    end

    def cash_refund_in_store
      transfer_balance_to_store(:cash_refund_in_store)
    end

    private

    def before_create
      super
      transfer_balance_to_store(:cash_in_store)
    end

    def transfer_balance_to_store(note_key)
      transfer_to_account(store, billing_account.balance, note_key)
    end

    def check_tickets
      tickets.each do |ticket|
        if ticket.changed?
          @update_printable = true
          break
        end
      end
    end

    def printable_dir_path(full = false)
      path = Rails.public_path if full
      File.join(path || "", "/system/tickets")
    end

    def update_printable
      FileUtils.mkdir_p(printable_dir_path(true))

      pdf = TicketsRetailPDF.new
      pdf.add_tickets tickets
      pdf.render_file(printable_path(true))
    end

    def check_printable
      if @update_printable
        update_printable
        @update_printable = false
      end
    end

    def delete_printable
      FileUtils.rm(printable_path(true), force: true)
    end
  end
end
