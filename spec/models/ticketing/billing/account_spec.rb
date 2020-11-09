# frozen_string_literal: true

RSpec.describe Ticketing::Billing::Account do
  describe 'associations' do
    it { is_expected.to belong_to(:billable).inverse_of(:billing_account) }
    it do
      is_expected.to have_many(:transfers)
        .inverse_of(:account).autosave(true).dependent(:destroy)
        .order(created_at: :desc)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:balance) }
  end

  shared_examples 'updates the balance' do
    it 'updates the balance' do
      expect { subject }.to change(account, :balance).by(transferred_amount)
    end
  end

  shared_examples 'creates a transfer' do
    it 'creates a transfer' do
      expect { subject }.to change(account.transfers, :count).by(1)
      transfer = account.transfers.last
      expect(transfer.amount).to eq(transferred_amount)
      expect(transfer.note_key).to eq(note_key.to_s)
    end
  end

  shared_examples 'does not update balance or create transfer' do
    it 'does not change the balance' do
      expect { subject }.not_to change(account, :balance)
    end

    it 'does not create a transfer' do
      expect { subject }.not_to change(Ticketing::Billing::Transfer, :count)
    end
  end

  shared_examples 'amount is zero' do
    context 'amount is zero' do
      let(:amount) { 0 }

      include_examples 'does not update balance or create transfer'
    end
  end

  shared_examples 'transfer of amount' do |negative|
    context 'amount is non-zero' do
      let(:amount) { 10 }
      let(:transferred_amount) { amount * (negative ? -1 : 1) }

      include_examples 'updates the balance'
      include_examples 'creates a transfer'
    end

    include_examples 'amount is zero'
  end

  describe '#balance' do
    let(:account) { create(:billing_account) }

    subject { account.balance }

    it { is_expected.to be_zero }
  end

  describe '#transfers' do
    let(:account) { create(:billing_account) }

    subject { account.transfers }

    it { is_expected.to be_empty }
  end

  describe '#deposit' do
    let(:account) { create(:billing_account) }
    let(:note_key) { :foobar }

    context 'depositing once' do
      subject do
        account.deposit(amount, note_key)
        account.save
      end

      include_examples 'transfer of amount'
    end

    context 'depositing twice' do
      let(:amount) { 10 }
      let(:transferred_amount) { amount * 2 }

      subject do
        2.times { account.deposit(amount, note_key) }
        account.save
      end

      include_examples 'updates the balance'
    end
  end

  describe '#withdraw' do
    let(:account) { create(:billing_account) }
    let(:note_key) { :foobar }

    context 'withdrawing once' do
      subject do
        account.withdraw(amount, note_key)
        account.save
      end

      include_examples 'transfer of amount', true
    end

    context 'withdrawing twice' do
      let(:amount) { 10 }
      let(:transferred_amount) { -amount * 2 }

      subject do
        2.times { account.withdraw(amount, note_key) }
        account.save
      end

      include_examples 'updates the balance'
    end
  end

  describe '#transfer' do
    let(:sender) { create(:billing_account) }
    let(:recipient) { create(:billing_account) }
    let(:amount) { 10 }
    let(:note_key) { :foobar }

    subject do
      sender.transfer(recipient, amount, note_key)
      sender.save
    end

    shared_examples 'updates the balance and creates transfer' do
      include_examples 'updates the balance'
      include_examples 'creates a transfer'
      include_examples 'amount is zero'

      it 'sets the participant' do
        subject
        expect(account.transfers.last.participant).to eq(participant)
      end

      it 'sets the reverse transfer' do
        subject
        expect(account.transfers.last.reverse_transfer)
          .to eq(participant.transfers.last)
      end

      context 'recipient is sender' do
        let(:recipient) { sender }

        include_examples 'does not update balance or create transfer'
      end
    end

    context 'sender' do
      let(:account) { sender }
      let(:participant) { recipient }
      let(:transferred_amount) { -amount }

      include_examples 'updates the balance and creates transfer'
    end

    context 'recipient' do
      let(:account) { recipient }
      let(:participant) { sender }
      let(:transferred_amount) { amount }

      include_examples 'updates the balance and creates transfer'
    end
  end

  describe '#outstanding?' do
    let(:account) { create(:billing_account) }

    subject { account.outstanding? }

    context 'zero balance' do
      it { is_expected.to be_falsy }
    end

    context 'positive balance' do
      before { account.deposit(10, nil) }

      it { is_expected.to be_falsy }
    end

    context 'negative balance' do
      before { account.deposit(-10, nil) }

      it { is_expected.to be_truthy }
    end
  end
end
