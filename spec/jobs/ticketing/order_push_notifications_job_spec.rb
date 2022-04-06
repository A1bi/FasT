# frozen_string_literal: true

RSpec.describe Ticketing::OrderPushNotificationsJob do
  let(:admin) { false }
  let(:order) { create(:order, :complete) }

  describe '#perform_later' do
    subject { described_class.perform_later(order, admin:) }

    it {
      expect { subject }.to have_enqueued_job(described_class).with(order, admin:)
    }
  end

  describe '#perform_now' do
    subject { described_class.perform_now(order, admin:) }

    let(:devices) { create_list(:push_notifications_device, 2, :stats) }
    let(:device_collection) { double }

    before do
      allow(Ticketing::PushNotifications::Device)
        .to receive(:where).with(app: :stats).and_return(device_collection)
      allow(device_collection).to receive(:find_each).and_yield(devices[0]).and_yield(devices[1])
    end

    context 'with ticket order' do
      shared_examples 'common payload' do
        let(:date) { 'January 1st 2001' }

        before do
          allow(I18n).to receive(:l).and_return(date)
        end

        it 'pushes the correct payload' do
          expect(devices).to all(receive(:push) do |payload|
            expect(payload[:title]).to include(order.event.name)
            expect(payload[:badge]).to eq(order.tickets.count)
            expect(payload[:sound]).to eq('cash.aif')
            expect(payload[:body]).to include(date)
            expect(payload[:body]).to include('Ticket')
          end)
          subject
        end
      end

      context 'with web order' do
        let(:order) { create(:web_order, :with_tickets) }

        include_examples 'common payload'

        context 'with regular order' do
          it 'includes online in body' do
            expect(devices).to all(receive(:push) do |payload|
              expect(payload[:body]).to include('online')
            end)
            subject
          end
        end

        context 'with admin order' do
          let(:admin) { true }

          it 'includes phone context in body' do
            expect(devices).to all(receive(:push) do |payload|
              expect(payload[:body]).to include('telefonisch')
            end)
            subject
          end
        end
      end

      context 'with retail order' do
        let(:order) { create(:retail_order, :with_tickets) }

        before do
          stub_const('Ticketing::TicketsRetailPdf', double.as_null_object)
        end

        include_examples 'common payload'

        it 'includes retail store name in body' do
          expect(devices).to all(receive(:push) do |payload|
            expect(payload[:body]).to include(order.store.name)
          end)
          subject
        end
      end

      context 'with box office order' do
        let(:order) { create(:box_office_order, :with_tickets) }

        include_examples 'common payload'

        it 'includes box office in body' do
          expect(devices).to all(receive(:push) do |payload|
            expect(payload[:body]).to include('Abendkasse')
          end)
          subject
        end
      end
    end

    context 'with coupon order' do
      let(:order) { create(:web_order, :with_purchased_coupons) }

      it 'pushes the correct payload' do
        expect(devices).to all(receive(:push) do |payload|
          expect(payload[:title]).to be_nil
          expect(payload[:body]).to include('Geschenkgutschein')
          expect(payload[:sound]).to eq('cash.aif')
        end)
        subject
      end
    end
  end
end
