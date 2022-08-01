# frozen_string_literal: true

RSpec.describe Ticketing::DebitSubmitService do
  subject { service.execute }

  let(:service) { described_class.new(orders, current_user: user) }
  let(:unsubmitted_orders) { create_list(:web_order, 2, :with_purchased_coupons, :with_balance, :charge_payment) }
  let!(:submitted_order) { create(:web_order, :with_purchased_coupons, :with_balance, :submitted_charge_payment) }
  let(:orders) { unsubmitted_orders + [submitted_order] }
  let(:user) { create(:user) }

  it 'only submits unsubmitted debits' do
    unsubmitted_orders.each do |order|
      expect(Ticketing::OrderPaymentService).to receive(:new).with(order, current_user: user).and_call_original
    end
    expect(Ticketing::OrderPaymentService).not_to receive(:new).with(submitted_order, anything)
    subject
  end

  it 'creates a new bank submission' do
    expect { subject }.to change(Ticketing::BankChargeSubmission, :count).by(1)
    charges = unsubmitted_orders.map(&:bank_charge)
    expect(Ticketing::BankChargeSubmission.last.charges).to include(*charges)
  end
end
