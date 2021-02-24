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

  describe '#approve_charge' do
    subject { service.approve_charge }

    context 'with an order with charge payment' do
      let(:order) do
        create(:web_order, :with_purchased_coupons, :charge_payment)
      end

      include_examples 'creates a log event', :approved

      it 'approves the bank charge' do
        expect { subject }.to change(order.bank_charge, :approved).to(true)
      end
    end

    context 'with an order without charge payment' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      include_examples 'does not create a log event'
    end
  end

  describe '#submit_charge' do
    subject { service.submit_charge }

    let(:order) do
      create(:web_order, :with_purchased_coupons, :charge_payment)
    end

    context 'with an approved charge' do
      before { order.bank_charge.update(approved: true) }

      context 'with an unsubmitted charge' do
        before { order.billing_account.update(balance: -50) }

        include_examples 'creates a log event', :submitted_charge

        it "sets the charge's amount" do
          expect { subject }.to change(order.bank_charge, :amount).to(50)
        end

        it "settles the order's balance" do
          expect { subject }.to change(order.billing_account, :balance).to(0)
        end
      end

      context 'with an already submitted charge' do
        before do
          Ticketing::BankSubmission.create(charges: [order.bank_charge])
        end

        include_examples 'does not create a log event'
      end
    end

    context 'with an unapproved bank charge' do
      include_examples 'does not create a log event'
    end
  end

  describe '#mark_as_paid' do
    subject { service.mark_as_paid }

    let(:order) { create(:web_order, :with_purchased_coupons, :unpaid) }

    before { order.billing_account.update(balance: -30) }

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
      let(:order) { create(:web_order, :with_purchased_coupons) }

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
      let(:order) { create(:web_order, :with_purchased_coupons, :unpaid) }

      include_examples 'creates a log event', :sent_pay_reminder
      include_examples 'sends an email', :pay_reminder
    end

    context 'with a retail order' do
      let(:order) { create(:retail_order, :with_purchased_coupons, :unpaid) }

      include_examples 'does not create a log event'
      include_examples 'does not send an email'
    end

    context 'with an already paid order' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      include_examples 'does not create a log event'
      include_examples 'does not send an email'
    end
  end

  describe '#refund_in_retail_store' do
    subject { service.refund_in_retail_store }

    let(:balance) { 55 }

    before { order.billing_account.update(balance: balance) }

    shared_examples 'does not change the balance' do
      it 'does not change the balance' do
        expect { subject }.not_to change(order.billing_account, :balance)
      end
    end

    context 'with a web order' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      include_examples 'does not change the balance'
    end

    context 'with a retail order' do
      let(:order) { create(:retail_order, :with_purchased_coupons, :unpaid) }

      context 'with a negative balance' do
        let(:balance) { -55 }

        include_examples 'does not change the balance'
      end

      context 'with a positive balance' do
        it 'settles the balance' do
          expect { subject }
            .to change(order.billing_account, :balance).from(balance).to(0)
        end

        it 'sets the right transfer note' do
          subject
          transfer = order.billing_account.transfers.last
          expect(transfer.note_key).to eq('cash_refund_in_store')
        end
      end
    end
  end
end
