# frozen_string_literal: true

require_shared_examples 'ticketing/billable'

RSpec.shared_examples 'generic order' do |order_factory|
  before { stub_const('TicketsRetailPdf', double.as_null_object) }

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
    it {
      is_expected
        .to have_many(:redeemed_coupons)
        .through(:coupon_redemptions).source(:coupon)
    }
    it {
      is_expected
        .to have_many(:purchased_coupons)
        .class_name('Ticketing::Coupon').dependent(:nullify)
        .with_foreign_key(:purchased_with_order_id)
        .inverse_of(:purchased_with_order).autosave(true)
    }
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

  describe '#update_total_and_billing' do
    let(:order) { create(order_factory, :complete) }
    let(:billing_account) { order.billing_account }
    let(:total) { order.tickets.sum(:price) }

    context 'order created' do
      # TODO: remove this exception for retail orders which is needed because
      # their total is balanced with their store's right away
      next if order_factory == :retail_order

      shared_examples 'sets total and balance' do
        it 'sets the correct initial total' do
          expect(order.total).to eq(total)
        end

        it 'withdraws the initial total from billing account' do
          expect(billing_account.balance).to eq(-total)
          expect(billing_account.transfers.first.note_key)
            .to eq('order_created')
        end
      end

      include_examples 'sets total and balance'

      context 'with purchased coupons' do
        let(:order) do
          create(order_factory, :complete, :with_purchased_coupons)
        end
        let(:total) { super() + order.purchased_coupons.sum(:amount) }

        include_examples 'sets total and balance'
      end
    end

    context 'a ticket has been cancelled' do
      let(:ticket) { order.tickets.first }
      let(:billing_note) { 'cancel_foo' }

      before { ticket.cancel(nil) }

      subject do
        order.update_total_and_billing(billing_note)
        order.save
      end

      it 'updates the total after changes' do
        expect { subject }.to change(order, :total).by(-ticket.price)
      end

      it 'updates the billing account' do
        expect { subject }
          .to change(billing_account, :balance).by(ticket.price)
        expect(billing_account.transfers.first.note_key).to eq(billing_note)
      end
    end
  end

  it_behaves_like 'billable'
end
