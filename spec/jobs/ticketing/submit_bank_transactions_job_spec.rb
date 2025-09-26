# frozen_string_literal: true

RSpec.describe Ticketing::SubmitBankTransactionsJob do
  describe '#perform_now' do
    subject { described_class.perform_now }

    let(:enabled) { true }
    let(:ebics) { instance_double(Ticketing::EbicsService) }
    let(:debit_xml_service) { instance_double(Ticketing::DebitSepaXmlService, xml: 'debits') }
    let(:transfer_xml_service) { instance_double(Ticketing::TransferSepaXmlService, xml: 'transfers') }

    before do
      allow(Settings.ebics).to receive(:enabled).and_return(enabled)
      allow(Ticketing::EbicsService).to receive(:new).and_return(ebics)
      allow(ebics).to receive_messages(submit_debits: %w[foo bar], submit_transfers: %w[bar foo])
      # create resources that should be ignored as they are not submittable
      create(:bank_debit, :submitted, :with_orders)
      create(:bank_refund, :submitted, :with_orders)
      create(:bank_transaction, :received, :with_orders)
    end

    shared_examples 'does nothing' do
      it 'creates no submissions' do
        expect { subject }.not_to change(Ticketing::BankSubmission, :count)
      end

      it 'does not submit anything' do
        expect(ebics).not_to receive(:submit_debits)
        expect(ebics).not_to receive(:submit_transfers)
        subject
      end
    end

    context 'with EBICS disabled' do
      let(:enabled) { false }

      it 'does not fetch transactions' do
        expect(Ticketing::BankTransaction).not_to receive(:submittable)
        subject
      end
    end

    context 'when no transactions are submittable' do
      it_behaves_like 'does nothing'
    end

    context 'when only debits are submittable' do
      let!(:debits) { create_list(:bank_debit, 2, :submittable, :with_orders) }

      it 'creates one submission' do
        expect { subject }.to change(Ticketing::BankSubmission, :count).by(1)
      end

      it 'creates a submission with the two submittable debits' do
        subject
        expect(Ticketing::BankSubmission.last.transactions).to match_array(debits)
      end

      it 'submits the correct payload' do
        expect(Ticketing::DebitSepaXmlService).to receive(:new) do |submission|
          expect(submission).to eq(Ticketing::BankSubmission.last)
        end.and_return(debit_xml_service)
        expect(ebics).to receive(:submit_debits).with('debits')
        subject
      end

      it 'stores the EBICS response' do
        subject
        expect(Ticketing::BankSubmission.last.ebics_response).to eq(%w[foo bar])
      end
    end

    context 'when only refunds are submittable' do
      let!(:refunds) { create_list(:bank_refund, 2, :submittable, :with_orders) }

      it 'creates one submission' do
        expect { subject }.to change(Ticketing::BankSubmission, :count).by(1)
      end

      it 'creates a submission with the two submittable refunds' do
        subject
        expect(Ticketing::BankSubmission.last.transactions).to match_array(refunds)
      end

      it 'submits the correct payload' do
        expect(Ticketing::TransferSepaXmlService).to receive(:new) do |submission|
          expect(submission).to eq(Ticketing::BankSubmission.last)
        end.and_return(transfer_xml_service)
        expect(ebics).to receive(:submit_transfers).with('transfers')
        subject
      end

      it 'stores the EBICS response' do
        subject
        expect(Ticketing::BankSubmission.last.ebics_response).to eq(%w[bar foo])
      end
    end

    context 'when both debits and refunds are submittable' do
      let!(:debits) { create_list(:bank_debit, 2, :submittable, :with_orders) }
      let!(:refunds) { create_list(:bank_refund, 2, :submittable, :with_orders) }

      it 'creates two submissions' do
        expect { subject }.to change(Ticketing::BankSubmission, :count).by(2)
      end

      it 'creates a submission with the two submittable debits' do
        subject
        expect(Ticketing::BankSubmission.second_to_last.transactions).to match_array(debits)
      end

      it 'creates a submission with the two submittable refunds' do
        subject
        expect(Ticketing::BankSubmission.last.transactions).to match_array(refunds)
      end

      it 'submits the correct payloads' do
        expect(Ticketing::DebitSepaXmlService).to receive(:new) do |submission|
          expect(submission.transactions).to match_array(debits)
        end.and_return(debit_xml_service)
        expect(Ticketing::TransferSepaXmlService).to receive(:new) do |submission|
          expect(submission.transactions).to match_array(refunds)
        end.and_return(transfer_xml_service)
        expect(ebics).to receive(:submit_debits).with('debits')
        expect(ebics).to receive(:submit_transfers).with('transfers')
        subject
      end

      it 'stores the EBICS responses' do
        subject
        expect(Ticketing::BankSubmission.second_to_last.ebics_response).to eq(%w[foo bar])
        expect(Ticketing::BankSubmission.last.ebics_response).to eq(%w[bar foo])
      end

      context 'when job is run twice' do
        before { described_class.perform_now }

        it_behaves_like 'does nothing'
      end
    end

    context 'when creating a submission fails' do
      before do
        create(:bank_debit, :submittable)
        allow(Ticketing::BankSubmission).to receive(:create!).and_raise(StandardError)
      end

      it 'does not submit via EBICS' do
        expect(ebics).not_to receive(:submit_debits)
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when EBICS submission fails' do
      before do
        create(:bank_debit, :submittable)
        allow(ebics).to receive(:submit_debits).and_raise(StandardError)
      end

      it 'creates no submissions' do
        expect { subject }.to raise_error(StandardError).and(not_change(Ticketing::BankSubmission, :count))
      end
    end

    context 'when some transactions lack orders' do
      before { create(:bank_debit, :submittable) }

      it 'creates no submissions' do
        expect { subject }.to raise_error(StandardError).and(not_change(Ticketing::BankSubmission, :count))
      end
    end

    context 'when an error happens after EBICS submission' do
      let!(:submittable_transactions) { create_list(:bank_debit, 2, :submittable, :with_orders) }
      let(:submission) { build(:bank_submission, transactions: submittable_transactions) }
      let(:exception) { StandardError.new('failed to update submission') }

      before do
        allow(Ticketing::BankSubmission).to receive(:create!) do
          submission.save
          submission
        end
        allow(submission).to receive(:update).and_raise(exception)
      end

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end

      it 'still creates a submission' do
        expect { subject }.to change(Ticketing::BankSubmission, :count).by(1)
      end

      it 'still marks the transactions as submitted' do
        subject
        expect(submission.reload.transactions).to match_array(submittable_transactions)
      end

      it 'captures the error' do
        expect(Sentry).to receive(:capture_exception).with(exception)
        subject
      end
    end
  end
end
