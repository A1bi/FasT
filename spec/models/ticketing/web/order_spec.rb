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

  describe '#due?' do
    subject { order.due? }

    let(:paid) { false }

    before do
      stub_const("#{described_class}::PAYMENT_DUE_AFTER", 1.week)
      order.update(paid:)
    end

    context 'with not yet due order' do
      let(:order) { create(:web_order, :complete, :transfer_payment) }

      it { is_expected.to be_falsy }
    end

    context 'with due order' do
      let(:order) { create(:web_order, :complete, :transfer_payment, created_at: 8.days.ago) }

      it { is_expected.to be_truthy }

      context 'with paid order' do
        let(:paid) { true }

        it { is_expected.to be_falsy }
      end
    end

    context 'with a due order with cash payment' do
      let(:order) { create(:web_order, :complete, :cash_payment, created_at: 8.days.ago) }

      it { is_expected.to be_falsy }
    end
  end

  describe '#overdue?' do
    subject { order.overdue? }

    let(:paid) { false }

    before do
      stub_const("#{described_class}::PAYMENT_DUE_AFTER", 1.week)
      stub_const("#{described_class}::PAYMENT_OVERDUE_AFTER", 2.weeks)
      order.update(paid:)
    end

    context 'with not yet overdue order' do
      let(:order) { create(:web_order, :complete, :transfer_payment) }

      it { is_expected.to be_falsy }
    end

    context 'with due but not overdue order' do
      let(:order) { create(:web_order, :complete, :transfer_payment, created_at: 8.days.ago) }

      it { is_expected.to be_falsy }
    end

    context 'with due order' do
      let(:order) { create(:web_order, :complete, :transfer_payment, created_at: 15.days.ago) }

      it { is_expected.to be_truthy }

      context 'with paid order' do
        let(:paid) { true }

        it { is_expected.to be_falsy }
      end
    end

    context 'with a due order with cash payment' do
      let(:order) { create(:web_order, :complete, :cash_payment, created_at: 15.days.ago) }

      it { is_expected.to be_falsy }
    end
  end
end
