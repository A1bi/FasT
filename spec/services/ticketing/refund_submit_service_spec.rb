# frozen_string_literal: true

RSpec.describe Ticketing::RefundSubmitService do
  subject { service.execute }

  let(:service) { described_class.new(orders, current_user: user) }
  let(:unsubmitted_orders) { create_list(:web_order, 2, :complete, :with_credit, :with_bank_refunds) }
  let!(:submitted_order) { create(:web_order, :complete, :with_credit, :with_bank_refunds) }
  let(:orders) { unsubmitted_orders + [submitted_order] }
  let(:user) { create(:user) }

  before { submitted_order.open_bank_refund.update(amount: 123, submission: build(:bank_refund_submission)) }

  it 'only submits unsubmitted debits' do
    unsubmitted_orders.each do |order|
      expect(Ticketing::OrderPaymentService).to receive(:new).with(order, current_user: user).and_call_original
    end
    expect(Ticketing::OrderPaymentService).not_to receive(:new).with(submitted_order, anything)
    subject
  end

  it 'creates a new bank submission' do
    refunds = unsubmitted_orders.map(&:open_bank_refund)
    expect { subject }.to change(Ticketing::BankRefundSubmission, :count).by(1)
    expect(Ticketing::BankRefundSubmission.last.refunds).to include(*refunds)
  end
end
