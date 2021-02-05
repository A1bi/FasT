# frozen_string_literal: true

RSpec.describe Ticketing::OrderCreateService do
  subject { service.execute }

  let(:service) { described_class.new(params) }
  let(:params) do
    {
      type: type,
      order: order_params
    }
  end
  let(:order_params) do
    {
      date: date_id,
      tickets: ticket_params
    }
  end
  let(:event) { create(:event, :complete) }
  let(:date_id) { event.dates.first.id }
  let(:ticket_params) { { event.ticket_types.first.id => 1 } }

  context 'with a web order' do
    let(:type) { :web }
    let(:order_params) do
      super().merge(
        address: address,
        payment: {
          method: :transfer
        }
      )
    end
    let(:address) do
      {
        first_name: FFaker::NameDE.first_name,
        last_name: FFaker::NameDE.last_name,
        gender: 0,
        email: FFaker::Internet.free_email,
        phone: FFaker::PhoneNumberDE.phone_number,
        plz: '13403'
      }
    end

    context 'when params are valid' do
      it 'sends a confirmation' do
        expect { subject }.to(
          have_enqueued_mail(Ticketing::OrderMailer, :confirmation)
            .with do |params|
              expect(params[:params][:order]).to eq(Ticketing::Order.last)
            end
        )
      end
    end

    context 'when params are invalid' do
      let(:address) { super().merge(email: 'foo') }

      it 'does not send a confirmation' do
        expect { subject }
          .not_to have_enqueued_mail(Ticketing::OrderMailer, :confirmation)
      end
    end
  end
end
