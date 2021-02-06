# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::OrderPaymentService do
  let(:service) { described_class.new(order) }
  let!(:loggable) { order } # rubocop:disable RSpec/LetSetup

  shared_examples 'does not send an email' do
    it 'does not send an email' do
      expect { subject }.not_to have_enqueued_mail(Ticketing::OrderMailer)
    end
  end

  shared_examples 'sends an email' do |action|
    it 'sends an email' do
      expect { subject }
        .to have_enqueued_mail(Ticketing::OrderMailer, action)
        .with(a_hash_including(params: { order: order }))
    end
  end

  describe '#mark_as_paid' do
    subject { service.mark_as_paid }

    let(:order) { create(:web_order, :with_purchased_coupons) }

    shared_examples 'marks as paid' do
      it 'updates the balance' do
        expect { subject }
          .to change { order.billing_account.reload.outstanding? }.to(false)
      end

      it 'creates a billing' do
        expect { subject }.to change(Ticketing::Billing::Transfer, :count).by(1)
        expect(order.billing_account.transfers.first.note_key)
          .to eq('payment_received')
      end
    end

    context 'with a web order' do
      include_examples 'marks as paid'
      include_examples 'creates a log event', :marked_as_paid
      include_examples 'sends an email', :payment_received
    end

    context 'with a retail order' do
      let(:order) { create(:retail_order, :with_purchased_coupons, :unpaid) }

      # TODO: remove this when retail orders no longer withdraw total from
      # balance on creation
      before do
        order.withdraw_from_account(10, nil)
        order.save
      end

      include_examples 'marks as paid'
      include_examples 'creates a log event', :marked_as_paid
    end

    context 'with an already paid order' do
      let(:order) { create(:web_order, :with_purchased_coupons, :paid) }

      include_examples 'does not create a log event'
      include_examples 'does not send an email'

      it 'does not create a billing' do
        expect { subject }.not_to change(Ticketing::Billing::Transfer, :count)
      end
    end
  end

  describe '#send_reminder' do
    subject { service.send_reminder }

    context 'with a web order' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      include_examples 'creates a log event', :sent_pay_reminder
      include_examples 'sends an email', :pay_reminder
    end

    context 'with a retail order' do
      let(:order) { create(:retail_order, :with_purchased_coupons) }

      include_examples 'does not create a log event'
      include_examples 'does not send an email'
    end

    context 'with an already paid order' do
      let(:order) { create(:web_order, :with_purchased_coupons, :paid) }

      include_examples 'does not create a log event'
      include_examples 'does not send an email'
    end
  end
end
