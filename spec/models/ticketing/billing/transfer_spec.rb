# frozen_string_literal: true

RSpec.describe Ticketing::Billing::Transfer do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it do
      is_expected.to belong_to(:participant)
        .class_name('Account').optional(true).autosave(true)
    end
    it do
      is_expected.to belong_to(:reverse_transfer)
        .class_name('Transfer').optional(true)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:amount) }
  end
end
