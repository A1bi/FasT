# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::TseTransactionCreateService do
  let(:box_office) { create(:box_office, tse_client_id: client_id) }
  let(:client_id) { 'foobar_id' }
  let(:purchase) { create(:box_office_purchase, :with_items, items_count: 3, box_office:, pay_method:) }
  let(:pay_method) { 'cash' }
  let(:service) { described_class.new(purchase) }
  let(:tse) { instance_double(Ticketing::Tse, send_admin_command: true) }
  let(:start_time) { 10.seconds.ago.round }
  let(:end_time) { 5.seconds.ago.round }
  let(:tse_device) { create(:tse_device) }
  let(:tse_serial_number) { tse_device&.serial_number }
  let(:start_response) do
    { TransactionNumber: 4711, LogTime: start_time.iso8601, SerialNumber: tse_serial_number }
  end
  let(:finish_response) do
    { SignatureCounter: 345, Signature: 'foofoo', LogTime: end_time.iso8601 }
  end

  before do
    allow(Ticketing::Tse).to receive(:connect).and_yield(tse)
    allow(tse).to receive(:send_time_admin_command).with('StartTransaction').and_return(start_response)
    allow(tse).to receive(:send_time_admin_command).with('FinishTransaction', anything).and_return(finish_response)
  end

  describe '#execute' do
    subject { service.execute }

    let(:new_client_id) { "FasT-POS-DEV-#{box_office.id}" }

    context 'when box office does not have a client id yet' do
      let(:client_id) { nil }

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
      it 'starts a transaction' do
        expect(tse).to receive(:send_time_admin_command).with('StartTransaction')
        subject
      end

      context 'when TSE device is not yet known' do
        let(:tse_device) { nil }
        let(:tse_serial_number) { 'serialfoo' }

        before do
          allow(tse)
            .to receive(:send_command).with('GetDeviceData', Name: 'PublicKey', Format: 'Base64')
            .and_return(Value: 'fookey')
        end

        it 'fetches the public key from the TSE device' do
          expect(tse).to receive(:send_command).with('GetDeviceData', Name: 'PublicKey', Format: 'Base64')
          subject
        end

        it 'creates a new TSE device' do
          expect { subject }.to change(Ticketing::TseDevice, :count).by(1)
        end

        it 'fill the new TSE device with the correct public key' do
          subject
          expect(purchase.tse_device.public_key).to eq('fookey')
        end
      end

      context 'when TSE device is already known' do
        it 'does not create a new TSE device' do
          expect { subject }.not_to change(Ticketing::TseDevice, :count)
        end

        it 'set the correct TSE device on the purchase' do
          expect { subject }.to change(purchase, :tse_device).to(tse_device)
        end
      end
    end

    describe 'finishing the transaction' do
      shared_examples 'finishes the transaction' do
        let(:process_data) { "Beleg^#{vat_totals}^#{payments}" }

        it 'finishes the transaction with the correct transaction number' do
          expect(tse).to receive(:send_time_admin_command).with('StartTransaction').ordered
          expect(tse).to receive(:send_time_admin_command) do |command, params|
            expect(command).to eq('FinishTransaction')
            expect(params[:TransactionNumber]).to eq(4711)
          end.and_return(finish_response)
          subject
        end

        it 'finishes the transaction with the correct process type and data' do
          expect(tse).to receive(:send_time_admin_command).with('StartTransaction').ordered
          expect(tse).to receive(:send_time_admin_command) do |command, params|
            expect(command).to eq('FinishTransaction')
            expect(params[:Typ]).to eq('Kassenbeleg-V1')
            expect(params[:Data]).to eq(process_data)
          end.and_return(finish_response)
          subject
        end

        it 'persists the TSE info to the database' do
          expect { subject }.to change(purchase, :tse_info).to(
            'client_id' => client_id,
            'process_type' => 'Kassenbeleg-V1',
            'process_data' => process_data,
            'transaction_number' => 4711,
            'signature_counter' => 345,
            'signature' => 'foofoo',
            'start_time' => start_time,
            'end_time' => end_time
          )
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

        it_behaves_like 'finishes the transaction'
      end

      context 'with the reduced VAT rate' do
        include_context 'with specific VAT rates' do
          let(:vat_rate) { :reduced }
        end

        let(:vat_totals) { '0.00_54.06_0.00_0.00_0.00' }
        let(:payments) { '54.06:Bar' }

        it_behaves_like 'finishes the transaction'
      end

      context 'with the zero VAT rate' do
        include_context 'with specific VAT rates' do
          let(:vat_rate) { :zero }
        end

        let(:vat_totals) { '0.00_0.00_0.00_0.00_54.06' }
        let(:payments) { '54.06:Bar' }

        it_behaves_like 'finishes the transaction'
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

        it_behaves_like 'finishes the transaction'
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

          it_behaves_like 'finishes the transaction'
        end

        context 'with cashless payment' do
          let(:pay_method) { 'electronic_cash' }
          let(:payments) { '7.38:Unbar' }

          it_behaves_like 'finishes the transaction'
        end
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
