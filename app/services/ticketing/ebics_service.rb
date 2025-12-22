# frozen_string_literal: true

module Ticketing
  class EbicsService
    def statement_entries(from, to = Time.zone.today)
      response = fetch_data do
        client.C53(from.to_date, to.to_date)
      end
      extract_entries(response.map(&:statements))
    end

    def intraday_entries
      response = fetch_data do
        client.C52(Time.zone.today, Time.zone.today)
      end
      extract_entries(response.map(&:reports))
    end

    def submit_debits(xml)
      client.debit(xml)
    end

    def submit_transfers(xml)
      client.credit(xml)
    end

    private

    def extract_entries(response)
      response.flatten.map(&:entries).flatten
    end

    def fetch_data
      yield.map { |xml| SepaFileParser::String.parse(xml) }
    rescue Epics::Error::BusinessError => e
      raise unless e.symbol == 'EBICS_NO_DOWNLOAD_DATA_AVAILABLE'

      []
    end

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
