# frozen_string_literal: true

module Ticketing
  class EbicsService
    def HPB
      client.HPB
    end

    def HAA
      client.HAA
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
