# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::TseTransactionCreateService do
  let(:box_office) { create(:box_office, tse_client_id: client_id) }
  let(:client_id) { nil }
  let(:purchase) { create(:box_office_purchase, :with_items, box_office:) }
  let(:service) { described_class.new(purchase) }
  let(:tse) { instance_double(Ticketing::Tse, send_admin_command: true, send_time_admin_command: true) }

  before do
    allow(Ticketing::Tse).to receive(:connect).and_yield(tse)
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

    context 'when the command fails' do
      before do
        allow(tse).to receive(:send_admin_command).and_raise(Ticketing::Tse::ResponseError, {})
      end

      it 'raises an error' do
        expect { subject }.to raise_error(Ticketing::Tse::ResponseError)
      end
    end
  end
end
