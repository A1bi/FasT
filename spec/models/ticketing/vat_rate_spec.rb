# frozen_string_literal: true

RSpec.describe Ticketing::VatRate do
  describe 'validations' do
    it { is_expected.to validate_numericality_of(:rate).is_greater_than(0) }
  end
end
