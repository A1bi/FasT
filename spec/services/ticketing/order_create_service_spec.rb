# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::OrderCreateService do
  subject { service.execute }

  let(:service) { described_class.new(params, current_user:) }
  let(:params) do
    {
      type:,
      order: order_params
    }
  end
  let(:order_params) do
    {
      date: date_id,
      tickets: ticket_params,
      coupon_codes: coupons.pluck(:code)
    }
  end
  let(:event) { create(:event, :complete) }
  let!(:free_ticket_type) { create(:ticket_type, :free, event:) }
  let(:date_id) { event.dates.first.id }
  let(:ticket_params) { { event.ticket_types[0].id => 2 } }
  let(:coupons) do
    [create(:coupon, :credit, value: 1),
     create(:coupon, :free_tickets, value: 1)]
  end
  let(:current_user) { nil }
  let(:order) { Ticketing::Order.last }
  let(:total) { event.ticket_types[0].price }
  let(:total_after_discount) { total - coupons.first.value }

  shared_examples 'marks order as paid' do |paid|
    it 'marks order as paid' do
      subject
      expect(order.paid).to eq(paid)
    end
  end

  context 'with a web order' do
    let(:type) { :web }
    let(:order_params) do
      super().merge(
        address:,
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
      it 'creates tickets with the correct type' do
        subject
        expect(order.tickets.count).to eq(2)
        expect(order.tickets[0].type).to eq(event.ticket_types[0])
        expect(order.tickets[1].type).to eq(free_ticket_type)
      end

      it 'redeems credit coupons' do
        subject
        expect(order.total).to eq(total)
        expect(order.billing_account.balance).to eq(-total_after_discount)
      end

      it 'sends a confirmation' do
        expect { subject }.to(
          have_enqueued_mail(Ticketing::OrderMailer, :confirmation)
            .with do |params|
              expect(params[:params][:order]).to eq(order)
            end
        )
      end

      include_examples 'creates a log event for a new record', :created do
        let(:loggable) { order }
      end
    end

    context 'when params are invalid' do
      let(:address) { super().merge(email: 'foo') }

      it 'does not send a confirmation' do
        expect { subject }.not_to have_enqueued_mail(Ticketing::OrderMailer, :confirmation)
      end
    end

    context 'with a transfer payment' do
      include_examples 'marks order as paid', false
    end

    context 'with charge payment' do
      let(:order_params) do
        super().merge(
          payment: {
            method: :charge,
            **attributes_for(:bank_debit).slice(:name, :iban)
          }
        )
      end

      it 'creates a bank transaction' do
        expect { subject }.to change(Ticketing::BankTransaction, :count).by(1)
      end

      it 'sets the correct bank debit details' do
        subject
        expect(order.open_bank_transaction.attributes)
          .to include(order_params[:payment].slice(:name, :iban).stringify_keys)
      end

      it 'adds the total to the bank transaction' do
        subject
        expect(order.open_bank_transaction.amount).to eq(total_after_discount)
      end

      it 'settles the order\'s balance' do
        subject
        expect(order.balance).to eq(0)
      end

      include_examples 'marks order as paid', true
    end
  end

  context 'with a retail order' do
    let(:type) { :retail }
    let(:store) { create(:retail_store) }
    let(:current_user) { create(:retail_user, store:) }

    before do
      pdf = double.as_null_object
      allow(Ticketing::TicketsRetailPdf).to receive(:new).and_return(pdf)
    end

    it 'withdraws from the retail billing account' do
      subject
      expect(order.billing_account.balance).to eq(0)
      expect(store.billing_account.balance).to eq(-total_after_discount)
    end

    include_examples 'marks order as paid', true
  end
end
