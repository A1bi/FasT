# frozen_string_literal: true

require_shared_examples 'ticketing/billable'

RSpec.shared_examples 'generic order' do |order_factory|
  before { stub_const('Ticketing::TicketsRetailPdf', double.as_null_object) }

  # let(:max_tickets) { 255 }

  describe 'attributes' do
    it { is_expected.to have_readonly_attribute(:date) }
  end

  describe 'associations' do
    it {
      expect(subject).to have_many(:tickets)
        .inverse_of(:order).dependent(:destroy).autosave(true)
        .order(:order_index)
    }

    it {
      expect(subject).to belong_to(:date)
        .class_name('Ticketing::EventDate').optional(true)
    }

    it { is_expected.to have_many(:coupon_redemptions).dependent(:destroy) }

    it {
      expect(subject).to have_many(:redeemed_coupons).through(:coupon_redemptions).source(:coupon)
    }

    it {
      expect(subject)
        .to have_many(:purchased_coupons)
        .class_name('Ticketing::Coupon').dependent(:nullify)
        .with_foreign_key(:purchased_with_order_id)
        .inverse_of(:purchased_with_order).autosave(true)
    }

    it {
      expect(subject).to have_many(:exclusive_ticket_type_credit_spendings)
        .class_name('Members::ExclusiveTicketTypeCreditSpending')
        .dependent(:destroy).autosave(true)
    }

    it {
      expect(subject).to have_many(:box_office_payments)
        .class_name('Ticketing::BoxOffice::OrderPayment')
        .dependent(:nullify)
    }
  end

  describe 'validations' do
    it {
      # TODO: wait for the following issue to get fixed
      # https://github.com/thoughtbot/shoulda-matchers/issues/1007
      # is_expected.to validate_length_of(:tickets).is_at_most(max_tickets)
    }

    describe 'items presence' do
      subject { build(order_factory) }

      it { is_expected.to be_invalid }

      it 'validates presence of items' do
        subject.valid?
        expect(subject.errors).to be_added(:base, :missing_items)
      end
    end
  end

  describe '.unpaid' do
    subject { described_class.unpaid }

    let!(:unpaid_order) { create(order_factory, :complete, :unpaid) }
    let!(:paid_order) { create(order_factory, :complete) }

    it 'only returns unpaid orders' do
      expect(subject).to include(unpaid_order)
      expect(subject).not_to include(paid_order)
    end
  end

  describe '.policy_class' do
    subject { described_class.policy_class }

    it { is_expected.to eq(Ticketing::OrderPolicy) }
  end

  describe '#items' do
    subject { order.items }

    context 'without items present' do
      let(:order) { build(order_factory) }

      it { is_expected.to be_empty }
    end

    context 'with tickets present' do
      let(:order) { create(order_factory, :with_tickets) }

      it { is_expected.to eq(order.tickets) }
    end

    context 'with coupons present' do
      let(:order) { create(order_factory, :with_purchased_coupons) }

      it { is_expected.to eq(order.purchased_coupons) }
    end

    context 'with tickets and coupons present' do
      let(:order) { create(order_factory, :with_tickets, :with_purchased_coupons) }

      it { is_expected.to eq(order.tickets + order.purchased_coupons) }
    end
  end

  describe '#update_total' do
    subject { order.update_total }

    let(:order) { create(order_factory, :with_tickets, tickets_count: 2) }
    let(:total) { order.tickets.last.price + 10 + 15 }

    before do
      create(:cancellation, tickets: [order.tickets.first])

      coupon = create(:coupon, :credit, value: 10, purchased_with_order: order)
      coupon.withdraw_from_account(10, :foo)
      order.purchased_coupons.reload

      # make sure this also takes unpersisted records into account
      coupon = order.purchased_coupons.build
      coupon.deposit_into_account(15, :foo)
    end

    it 'sets the correct total (excluding the cancelled ticket)' do
      expect { subject }.to change(order, :total).from(0).to(total)
    end

    it 'returns the new total' do
      expect(subject).to eq(total)
    end
  end

  it_behaves_like 'billable'
end
