# frozen_string_literal: true

require 'support/authentication'
require 'support/ticketing/statistics'

RSpec.describe 'Ticketing::StatisticsController' do
  describe 'GET #map_data' do
    subject { get ticketing_statistics_map_data_path(format: :json) }

    let(:user) { build(:user, :admin) }
    let(:geolocations) { create_list(:geolocation, 3) }

    before do
      sign_in(user:)

      create_orders(1, 2)
      create(:web_order, :complete, plz: '99999')
      create_orders(0, 1)
      create_orders(2, 4)
    end

    it 'returns the correct postcodes and number of orders' do
      subject
      expect(response.parsed_body).to eq(
        'locations' => [
          location_response(2, 4),
          location_response(1, 2),
          location_response(0, 1)
        ]
      )
    end
  end
end
