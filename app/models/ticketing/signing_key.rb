# frozen_string_literal: true

module Ticketing
  class SigningKey < ApplicationRecord
    MINIMUM_NUMBER_OF_KEYS = 5
    SECRET_LENGTH = 32

    attr_readonly :secret

    validates :secret, presence: true
    validates :active, inclusion: [true, false]

    after_initialize :after_initialize

    def self.active
      where(active: true)
    end

    def self.random_active
      (MINIMUM_NUMBER_OF_KEYS - count).times do
        create
      end

      active.offset(rand(count)).first
    end

    def sign_ticket(ticket, params = {})
      sign_record(params.merge(ticket:))
    end

    def sign_order(order, params = {})
      sign_record(params.merge(order:))
    end

    def self.verify_info(data)
      begin
        data = decode_data(data)
        info = Ticketing::SignedInfoBinary.read(data)
      rescue StandardError
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
      return unless new_record?

      self[:active] = true
      self[:secret] = SecureRandom.hex(SECRET_LENGTH / 2)
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
