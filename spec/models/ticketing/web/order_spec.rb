# frozen_string_literal: true

require_shared_examples 'ticketing/orders'
require_shared_examples 'anonymizable'

RSpec.describe Ticketing::Web::Order do
  it_behaves_like 'generic order', :web_order

  it_behaves_like 'anonymizable', %i[email first_name last_name gender
                                     affiliation phone] do
    let(:record) { create(:web_order, :with_purchased_coupons) }
    let(:records) { create_list(:web_order, 2, :with_purchased_coupons) }
  end

  describe '.charges_to_submit' do
    subject { described_class.charges_to_submit }

    let!(:unsubmitted_orders) { create_list(:web_order, 2, :complete, :with_balance, :charge_payment) }

    before do
      create(:web_order, :complete, :with_balance, :transfer_payment)
      charge = build(:bank_charge, :with_amount, :submitted)
      create(:web_order, :complete, :charge_payment)
      create(:web_order, :complete, :with_balance, :charge_payment, bank_charge: charge)
    end

    it { is_expected.to contain_exactly(*unsubmitted_orders) }
  end
end
