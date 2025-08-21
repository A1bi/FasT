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
        measurements: {
          stage: {
            temperature: 11.1,
            humidity: 44.4,
            updated_at: 2.minutes.ago
          },
          costumes: {
            temperature: 22.2,
            humidity: 55.5,
            updated_at: 3.minutes.ago
          }
        }
      }
    end
  end
end
