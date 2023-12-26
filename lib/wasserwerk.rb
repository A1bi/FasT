# frozen_string_literal: true

class Wasserwerk
  include HTTParty
  base_uri 'https://api.wasserwerk.theater-kaisersesch.de'
  headers 'Authorization' => "Bearer #{Rails.application.credentials.wasserwerk_api_token}"

  class << self
    def state
      return fake_response if Settings.wasserwerk.fake_api

      response = get('/state')
      raise 'Error' unless response.success?

      response.parsed_response
    end

    def furnace_level=(level)
      return if Settings.wasserwerk.fake_api

      response = patch('/furnace', body: { level: })
      raise 'Error' unless response.success?
    end

    private

    def fake_response
      {
        furnace: { level: 3 },
        temperatures: { stage: 11.1, costumes: 22.2 },
        humidities: { stage: 44.4, costumes: 55.5 }
      }
    end
  end
end
