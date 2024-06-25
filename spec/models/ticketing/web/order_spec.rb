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

  describe 'validations' do
    subject { build(:web_order, pay_method) }

    let(:stripe_enabled) { true }

    before { allow(Settings.stripe).to receive(:enabled).and_return(stripe_enabled) }

    shared_examples 'no error on pay_method' do
      it 'has no error on pay_method' do
        subject.valid?
        expect(subject.errors).not_to be_added(:pay_method)
      end
    end

    context 'with charge payment' do
      let(:pay_method) { :charge_payment }

      include_examples 'no error on pay_method'
    end

    context 'with Stripe payment' do
      let(:pay_method) { :stripe_payment }

      include_examples 'no error on pay_method'

      context 'with existing order' do
        subject! { create(:web_order, :complete, :stripe_payment) }

        it 'successfully validates the order' do
          allow(Settings.stripe).to receive(:enabled).and_return(false)
          subject.valid?
          expect(subject.errors).not_to be_added(:pay_method)
        end
      end

      context 'with Stripe disabled' do
        let(:stripe_enabled) { false }

        it 'has an error on pay_method' do
          subject.valid?
          expect(subject.errors).to be_added(:pay_method, :exclusion, value: 'stripe')
        end
      end
    end
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
