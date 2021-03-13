# frozen_string_literal: true

RSpec.describe Ticketing::Billing::Transaction do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }

    it do
      expect(subject).to belong_to(:participant)
        .class_name('Account').optional(true).autosave(true)
    end

    it do
      expect(subject).to belong_to(:reverse_transaction)
        .class_name('Transaction').optional(true)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:amount) }
  end
end
