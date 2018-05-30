module Ticketing
  class SigningKey < BaseModel
    @@minimum_number_of_keys = 5
    @@secret_length = 32

    attr_readonly :secret

    validates_presence_of :secret
    validates :active, inclusion: [true, false]

    after_initialize :after_initialize

    def self.random_active
      (@@minimum_number_of_keys - count).times do
        create
      end

      where(active: true).offset(rand(count)).first
    end

    def sign_ticket(ticket, medium = nil)
      ticket_data = Ticketing::TicketBinary.from_ticket(ticket, signing_key: self, medium: medium)
      signature = generate_digest(ticket_data.to_binary_s)
      data = Ticketing::SignedTicketBinary.new(ticket: ticket_data, signature: signature)
      self.class.encode_data(data.to_binary_s)
    end

    def self.verify_ticket(data)
      begin
        data = decode_data(data)
        signed = Ticketing::SignedTicketBinary.read(data)
      rescue
        return false
      end

      ticket_data = signed[:ticket]
      key = find(ticket_data[:key_id])
      return false unless key.verify(ticket_data.to_binary_s, signed[:signature])

      Ticketing::Ticket.find_by_id(ticket_data[:id])
    end

    def verify(data, signature)
      generate_digest(data) == signature
    end

    def self.encode_data(data)
      Base64.urlsafe_encode64(data, padding: false)
    end

    def self.decode_data(data)
      Base64.urlsafe_decode64(data)
    end

    private

    def after_initialize
      if new_record?
        self[:active] = true
        self[:secret] = SecureRandom.hex(@@secret_length)
      end
    end

    def generate_digest(data)
      require 'openssl' unless defined?(OpenSSL)
      OpenSSL::HMAC.digest('sha1', secret, data)
    end
  end
end
