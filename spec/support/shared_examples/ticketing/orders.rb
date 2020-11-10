# frozen_string_literal: true

RSpec.shared_examples 'generic order' do
  # let(:max_tickets) { 256 }

  describe 'attributes' do
    it { is_expected.to have_readonly_attribute(:date) }
  end

  describe 'associations' do
    it {
      is_expected.to have_many(:tickets)
        .inverse_of(:order).dependent(:destroy).autosave(true)
        .order(:order_index)
    }
    it { is_expected.to belong_to(:date).class_name('Ticketing::EventDate') }
    it { is_expected.to have_many(:coupon_redemptions).dependent(:destroy) }
    it { is_expected.to have_many(:coupons).through(:coupon_redemptions) }
    it {
      is_expected.to have_many(:exclusive_ticket_type_credit_spendings)
        .class_name('Members::ExclusiveTicketTypeCreditSpending')
        .dependent(:destroy).autosave(true)
    }
    it {
      is_expected.to have_many(:box_office_payments)
        .class_name('Ticketing::BoxOffice::OrderPayment')
        .dependent(:nullify)
    }
  end

  describe 'validations' do
    it {
      # TODO: wait for the following issue to get fixed
      # https://github.com/thoughtbot/shoulda-matchers/issues/1007
      # is_expected.to validate_length_of(:tickets)
      #   .is_at_least(1).is_at_most(max_tickets)
    }
    it { is_expected.to validate_presence_of(:date) }
  end
end
