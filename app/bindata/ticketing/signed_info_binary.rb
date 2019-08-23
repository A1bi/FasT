module Ticketing
  class SignedInfoBinary < BinData::Record
    # workaround for BinData bug with enabled eager loading
    Ticketing::TicketBinary
    Ticketing::OrderBinary

    INFO_TYPES = { ticket: 0, order: 1 }.freeze

    bit4          :version, asserted_value: 1
    bit8          :signing_key_id
    bit4          :info_type

    ticket_binary :ticket, onlyif: -> { info_type == INFO_TYPES[:ticket] }
    order_binary  :order, onlyif: -> { info_type == INFO_TYPES[:order] }

    bit4          :authenticated
    bit4          :medium
    string        :signature, length: 20

    def self.from_record(params)
      INFO_TYPES.each do |type, index|
        next if params[type].blank?
        info = "Ticketing::#{type.capitalize}Binary".constantize.send("from_#{type}", params[type])
        params.merge!(
          info_type: index,
          type => info
        )
      end

      params[:medium] = Ticketing::CheckIn.medium_index(params[:medium])
      params[:authenticated] = params[:authenticated].present? ? 1 : 0

      new(params)
    end

    def sign
      self.signature = yield(data_to_sign)
    end

    def data_to_sign
      to_binary_s[0...signature.abs_offset]
    end

    def self.max_length
      record = new
      max = 0
      INFO_TYPES.each do |type, index|
        record.info_type = index
        max = [max, record.to_binary_s.length].max
      end
      max
    end
  end
end
