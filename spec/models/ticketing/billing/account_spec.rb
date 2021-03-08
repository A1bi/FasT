# frozen_string_literal: true

RSpec.describe Ticketing::Billing::Account do
  describe 'associations' do
    it { is_expected.to belong_to(:billable).inverse_of(:billing_account) }

    it do
      expect(subject).to have_many(:transfers)
        .inverse_of(:account).dependent(:destroy).order(created_at: :desc)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:balance) }
  end

  shared_examples 'updates the balance' do
    it 'updates the balance' do
      expect { subject }
        .to change { account.reload.balance }.by(transferred_amount)
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
    context 'with zero amount' do
      let(:amount) { 0 }

      include_examples 'does not update balance or create transfer'
    end
  end

  shared_examples 'transfer of amount' do |negative|
    context 'with non-zero amount' do
      let(:amount) { 10 }
      let(:transferred_amount) { amount * (negative ? -1 : 1) }

      include_examples 'updates the balance'
      include_examples 'creates a transfer'
    end

    include_examples 'amount is zero'
  end

  describe '#balance' do
    subject { account.balance }

    let(:account) { create(:billing_account) }

    it { is_expected.to be_zero }
  end

  describe '#transfers' do
    subject { account.transfers }

    let(:account) { create(:billing_account) }

    it { is_expected.to be_empty }
  end

  describe '#deposit' do
    let(:account) { create(:billing_account) }
    let(:note_key) { :foobar }

    context 'when depositing once' do
      subject do
        account.deposit(amount, note_key)
        account.save
      end

      include_examples 'transfer of amount'
    end

    context 'when depositing twice' do
      subject do
        2.times { account.deposit(amount, note_key) }
        account.save
      end

      let(:amount) { 10 }
      let(:transferred_amount) { amount * 2 }

      include_examples 'updates the balance'
    end
  end

  describe '#withdraw' do
    let(:account) { create(:billing_account) }
    let(:note_key) { :foobar }

    context 'when withdrawing once' do
      subject do
        account.withdraw(amount, note_key)
        account.save
      end

      include_examples 'transfer of amount', true
    end

    context 'when withdrawing twice' do
      subject do
        2.times { account.withdraw(amount, note_key) }
        account.save
      end

      let(:amount) { 10 }
      let(:transferred_amount) { -amount * 2 }

      include_examples 'updates the balance'
    end
  end

  describe '#transfer' do
    subject do
      sender.transfer(recipient, amount, note_key)
      sender.save
    end

    let(:sender) { create(:billing_account) }
    let(:recipient) { create(:billing_account) }
    let(:amount) { 10 }
    let(:note_key) { :foobar }

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

      context 'when recipient is sender' do
        let(:recipient) { sender }

        include_examples 'does not update balance or create transfer'
      end
    end

    context 'when checking the sender\'s account' do
      let(:account) { sender }
      let(:participant) { recipient }
      let(:transferred_amount) { -amount }

      include_examples 'updates the balance and creates transfer'
    end

    context 'when checking the recipient\'s account' do
      let(:account) { recipient }
      let(:participant) { sender }
      let(:transferred_amount) { amount }

      include_examples 'updates the balance and creates transfer'
    end
  end

  describe '#outstanding?' do
    subject { account.outstanding? }

    let(:account) { create(:billing_account) }

    context 'with zero balance' do
      it { is_expected.to be_falsy }
    end

    context 'with positive balance' do
      before { account.deposit(10, nil) }

      it { is_expected.to be_falsy }
    end

    context 'with negative balance' do
      before { account.deposit(-10, nil) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#credit?' do
    subject { account.credit? }

    let(:account) { create(:billing_account) }

    context 'with zero balance' do
      it { is_expected.to be_falsy }
    end

    context 'with positive balance' do
      before { account.deposit(10, nil) }

      it { is_expected.to be_truthy }
    end

    context 'with negative balance' do
      before { account.deposit(-10, nil) }

      it { is_expected.to be_falsy }
    end
  end
end
