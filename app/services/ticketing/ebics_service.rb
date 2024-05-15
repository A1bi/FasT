# frozen_string_literal: true

module Ticketing
  class EbicsService
    def statements(from, to = Time.zone.today)
      sta = client.STA(from, to)
      Cmxl.parse(sta, encoding: 'ISO-8859-1')
    rescue Epics::Error::BusinessError => e
      raise unless e.symbol == 'EBICS_NO_DOWNLOAD_DATA_AVAILABLE'

      []
    end

    def transactions(from, to = Time.zone.today)
      statements(from, to).map(&:transactions).flatten
    end

    def submit_debits(xml)
      client.debit(xml)
    end

    def submit_transfers(xml)
      client.credit(xml)
    end

    private

    def client
      @client ||= Epics::Client.new(keys, credentials.secret, settings.url, settings.host_id,
                                    credentials.user_id, credentials.partner_id)
    end

    def keys
      Rails.root.join('config/ebics.key').open
    end

    def credentials
      Rails.application.credentials.ebics
    end

    def settings
      Settings.ebics
    end
  end
end
