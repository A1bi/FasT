# frozen_string_literal: true

RSpec.shared_examples 'billable' do
  describe 'associations' do
    it do
      expect(subject)
        .to have_one(:billing_account)
        .class_name('Ticketing::Billing::Account')
        .inverse_of(:billable).autosave(true).dependent(:destroy)
    end
  end

  describe 'transfer methods' do
    let(:record) { described_class.new }
    let(:amount) { 2.5 }
    let(:note_key) { :foo }
    let(:after_transfer_callback_receiver) { record }

    shared_examples 'calls the after transfer callback' do
      it 'calls the after transfer callback' do
        expect(after_transfer_callback_receiver)
          .to receive(:after_account_transfer)
        subject
      end
    end

    describe '#withdraw_from_account' do
      subject { record.withdraw_from_account(amount, note_key) }

      it 'withdraws the amount from the billing account' do
        expect(record.billing_account)
          .to receive(:withdraw).with(amount, note_key)
        subject
      end

      include_examples 'calls the after transfer callback'
    end

    describe '#deposit_into_account' do
      subject { record.deposit_into_account(amount, note_key) }

      it 'deposits the amount into the billing account' do
        expect(record.billing_account)
          .to receive(:deposit).with(amount, note_key)
        subject
      end

      include_examples 'calls the after transfer callback'
    end

    describe '#transfer_to_account' do
      subject { record.transfer_to_account(recipient, amount, note_key) }

      let(:recipient) { record.dup }

      it 'transfers the amount to the billing account of the recipient' do
        expect(record.billing_account)
          .to receive(:transfer)
          .with(recipient.billing_account, amount, note_key)
        subject
      end

      include_examples 'calls the after transfer callback'

      context 'when recipient receives callback' do
        let(:after_transfer_callback_receiver) { recipient }

        include_examples 'calls the after transfer callback'
      end
    end
  end
end
