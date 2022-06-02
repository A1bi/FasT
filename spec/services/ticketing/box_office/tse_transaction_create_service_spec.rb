# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::TseTransactionCreateService do
  let(:box_office) { create(:box_office, tse_client_id: client_id) }
  let(:client_id) { nil }
  let(:purchase) { create(:box_office_purchase, :with_items, items_count: 3, box_office:, pay_method:) }
  let(:pay_method) { 'cash' }
  let(:service) { described_class.new(purchase) }
  let(:tse) { instance_double(Ticketing::Tse, send_admin_command: true) }
  let(:start_time) { 10.seconds.ago.round }
  let(:end_time) { 5.seconds.ago.round }
  let(:start_response) do
    { TransactionNumber: 4711, SerialNumber: 'hello', LogTime: start_time.iso8601 }
  end
  let(:finish_response) do
    { SignatureCounter: 345, Signature: 'foofoo', LogTime: end_time.iso8601 }
  end

  before do
    allow(Ticketing::Tse).to receive(:connect).and_yield(tse)
    allow(tse).to receive(:send_time_admin_command).with('StartTransaction', anything).and_return(start_response)
    allow(tse).to receive(:send_time_admin_command).with('FinishTransaction', anything).and_return(finish_response)
  end

  describe '#execute' do
    subject { service.execute }

    let(:new_client_id) { "FasT-POS-DEV-#{box_office.id}" }

    context 'when box office does not have a client id yet' do
      it 'connects to the TSE with a new client id' do
        expect(Ticketing::Tse).to receive(:connect).with(new_client_id)
        subject
      end

      it 'registers the new client id with the TSE' do
        expect(tse).to receive(:send_admin_command) do |command, params|
          expect(command).to eq('RegisterClientID')
          expect(params[:ClientID]).to eq(new_client_id)
        end
        subject
      end

      it 'persists the new client id' do
        expect { subject }.to change(box_office, :tse_client_id).to(new_client_id)
      end
    end

    context 'when box office does already have a registered client id' do
      let(:client_id) { 'foobar_id' }

      it 'connects to the TSE with the existing client id' do
        expect(Ticketing::Tse).to receive(:connect).with(client_id)
        subject
      end

      it 'does not register a new client id' do
        expect(tse).not_to receive(:send_admin_command).with('RegisterClientID', anything)
        subject
      end

      it 'does not change the saved client id' do
        expect { subject }.not_to(change { box_office.reload.tse_client_id })
      end
    end

    describe 'starting the transaction' do
      shared_examples 'starts a transaction' do
        it 'starts a transaction with the correct process type and data' do
          expect(tse).to receive(:send_time_admin_command) do |command, params|
            expect(command).to eq('StartTransaction')
            expect(params[:Typ]).to eq('Kassenbeleg-V1')
            expect(params[:Data]).to eq("Beleg^#{vat_totals}^#{payments}")
          end.and_return(start_response)
          subject
        end
      end

      shared_context 'with specific VAT rates' do
        before do
          3.times.each do |i|
            purchase.items[i].purchasable.update(vat_rate:)
            purchase.items[i].update(total: 9.01 * (i + 1))
          end
          purchase.update(total: 54.06)
        end
      end

      context 'with the standard VAT rate' do
        include_context 'with specific VAT rates' do
          let(:vat_rate) { :standard }
        end

        let(:vat_totals) { '54.06_0.00_0.00_0.00_0.00' }
        let(:payments) { '54.06:Bar' }

        include_examples 'starts a transaction'
      end

      context 'with the reduced VAT rate' do
        include_context 'with specific VAT rates' do
          let(:vat_rate) { :reduced }
        end

        let(:vat_totals) { '0.00_54.06_0.00_0.00_0.00' }
        let(:payments) { '54.06:Bar' }

        include_examples 'starts a transaction'
      end

      context 'with the zero VAT rate' do
        include_context 'with specific VAT rates' do
          let(:vat_rate) { :zero }
        end

        let(:vat_totals) { '0.00_0.00_0.00_0.00_54.06' }
        let(:payments) { '54.06:Bar' }

        include_examples 'starts a transaction'
      end

      context 'with multiple different VAT rates' do
        before do
          purchase.items[..1].each do |item|
            item.purchasable.update(vat_rate: :standard)
            item.update(total: 5.09)
          end
          purchase.items[2].purchasable.update(vat_rate: :reduced)
          purchase.items[2].update(total: 24.11)
          purchase.update(total: 34.29)
        end

        let(:vat_totals) { '10.18_24.11_0.00_0.00_0.00' }
        let(:payments) { '34.29:Bar' }

        include_examples 'starts a transaction'
      end

      describe 'payments' do
        let(:vat_totals) { '7.38_0.00_0.00_0.00_0.00' }

        before do
          3.times.each do |i|
            purchase.items[i].purchasable.update(vat_rate: :standard)
            purchase.items[i].update(total: 1.23 * (i + 1))
          end
          purchase.update(total: 7.38)
        end

        context 'with cash payment' do
          let(:payments) { '7.38:Bar' }

          include_examples 'starts a transaction'
        end

        context 'with cashless payment' do
          let(:pay_method) { 'electronic_cash' }
          let(:payments) { '7.38:Unbar' }

          include_examples 'starts a transaction'
        end
      end
    end

    describe 'finishing the transaction' do
      it 'finishes the transaction' do
        expect(tse).to receive(:send_time_admin_command).with('StartTransaction', anything).ordered
        expect(tse).to receive(:send_time_admin_command) do |command, params|
          expect(command).to eq('FinishTransaction')
          expect(params[:TransactionNumber]).to eq(4711)
        end.and_return(finish_response)
        subject
      end

      it 'persists the TSE info to the database' do
        expect { subject }.to change(purchase, :tse_info).to(
          'transaction_number' => 4711,
          'serial_number' => 'hello',
          'signature_counter' => 345,
          'signature' => 'foofoo',
          'start_time' => start_time,
          'end_time' => end_time
        )
      end
    end

    context 'when the command fails' do
      before do
        allow(tse).to receive(:send_time_admin_command).and_raise(Ticketing::Tse::ResponseError, {})
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Ticketing::Tse::ResponseError)
      end
    end
  end
end
