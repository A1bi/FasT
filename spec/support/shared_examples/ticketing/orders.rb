# frozen_string_literal: true

require_shared_examples 'ticketing/billable'

RSpec.shared_examples 'generic order' do |order_factory|
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

  describe '.unpaid' do
    subject { described_class.unpaid }

    before { stub_const('TicketsRetailPdf', double.as_null_object) }

    let!(:unpaid_order) { create(order_factory, :complete, :unpaid) }
    let!(:paid_order) { create(order_factory, :complete, :paid) }

    it 'only returns unpaid orders' do
      expect(subject).to include(unpaid_order)
      expect(subject).not_to include(paid_order)
    end
  end

  describe '.policy_class' do
    subject { described_class.policy_class }

    it { is_expected.to eq(Ticketing::OrderPolicy) }
  end

  it_behaves_like 'billable'
end
