# frozen_string_literal: true

RSpec.describe Ticketing::CheckIn do
  describe 'associations' do
    it { is_expected.to belong_to(:ticket) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:medium) }
    it { is_expected.to validate_presence_of(:date) }
  end
end
