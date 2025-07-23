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

      it_behaves_like 'no error on pay_method'
    end

    context 'with Stripe payment' do
      let(:pay_method) { :stripe_payment }

      it_behaves_like 'no error on pay_method'

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

  describe '.date_imminent' do
    subject { described_class.date_imminent }

    let(:event) { create(:event, :complete, dates_count: 2) }
    let!(:order) { create(:web_order, :with_tickets, event:, date: event.dates.first) }

    before do
      event.dates.each.with_index { |date, i| date.update(date: i.days.from_now) }
      create(:web_order, :with_tickets, event:, date: event.dates.last)
    end

    it { is_expected.to contain_exactly(order) }
    it { is_expected.to be_a ActiveRecord::Relation }
  end

  describe '#payment_overdue?' do
    subject { order.payment_overdue? }

    let(:order) { build(:web_order, :unpaid, created_at:) }
    let(:created_at) { Time.current }

    context 'with not yet overdue order' do
      it { is_expected.to be_falsy }
    end

    context 'with overdue order' do
      let(:created_at) { 15.days.ago }

      it { is_expected.to be_truthy }

      context 'with paid order' do
        before { order.paid = true }

        it { is_expected.to be_falsy }
      end

      context 'with cash payment' do
        let(:order) { build(:web_order, :unpaid, :cash_payment, created_at:) }

        it { is_expected.to be_falsy }
      end
    end
  end
end
