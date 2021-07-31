# frozen_string_literal: true

RSpec.describe Ticketing::Location do
  describe '#address' do
    subject { location.address }

    let(:location) { build(:location, street: 'Sample Street 1', postcode: '12121', city: 'Foo City') }

    it { is_expected.to eq('Sample Street 1, 12121 Foo City') }
  end
end
