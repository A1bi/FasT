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

    def sign_ticket(ticket, params = {})
      sign_record(params.merge(ticket: ticket))
    end

    def sign_order(order, params = {})
      sign_record(params.merge(order: order))
    end

    def self.verify_info(data)
      begin
        data = decode_data(data)
        info = Ticketing::SignedInfoBinary.read(data)
      rescue
        return false
      end

      key = find(info.signing_key_id)
      return false unless key.verify(info.data_to_sign, info.signature)

      info
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

    def self.max_info_length
      # calculate length after base64 encoding
      (Ticketing::SignedInfoBinary.max_length / 3.0).ceil * 4
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

    def sign_record(params)
      info = Ticketing::SignedInfoBinary.from_record(params.merge(signing_key_id: id))
      info.sign { |data| generate_digest(data) }
      self.class.encode_data(info.to_binary_s)
    end
  end
end
