# frozen_string_literal: true

RSpec.describe Ticketing::DebitSubmitService do
  subject { service.execute }

  let(:service) { described_class.new(orders, current_user: user) }
  let(:orders) do
    create_list(:web_order, 4, :with_purchased_coupons, :charge_payment)
  end
  let(:user) { create(:user) }

  before do
    orders[0..2].each { |order| order.bank_charge.update(approved: true) }
    Ticketing::BankSubmission.create(charges: [orders[2].bank_charge])
  end

  it 'only submits approved and unsubmitted debits' do
    orders[0..1].each do |order|
      expect(Ticketing::OrderPaymentService)
        .to receive(:new).with(order, current_user: user).and_call_original
    end
    subject
  end

  it 'creates a new bank submission' do
    expect { subject }.to change(Ticketing::BankSubmission, :count).by(1)
    charges = orders[0..1].map(&:bank_charge)
    expect(Ticketing::BankSubmission.last.charges).to include(*charges)
  end
end
