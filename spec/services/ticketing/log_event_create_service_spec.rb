# frozen_string_literal: true

require_shared_examples 'ticketing/loggable'

RSpec.describe Ticketing::LogEventCreateService do
  let(:service) { described_class.new(loggable, current_user: user) }
  let(:loggable) { create(:coupon) }
  let(:user) { create(:user) }
  let(:order) { create(:web_order, :with_tickets) }

  shared_examples 'creates a log event for web orders only' do |event|
    context 'with a web order' do
      let(:loggable) { order }

      include_examples 'creates a log event', event
    end

    include_examples 'does not create a log event'
  end

  describe '#create' do
    subject { service.create }

    include_examples 'creates a log event', :created
  end

  describe '#update' do
    subject { service.update }

    include_examples 'creates a log event', :updated
  end

  describe '#mark_as_paid' do
    subject { service.mark_as_paid }

    include_examples 'creates a log event', :marked_as_paid
  end

  describe '#redeem' do
    subject { service.redeem }

    include_examples 'creates a log event', :redeemed
  end

  describe '#send' do
    subject { service.send(**params) }

    let(:params) { { email: 'foo@bar.com', recipient: 'foobar' } }

    include_examples 'creates a log event', :sent do
      let(:info) { params }
    end
  end

  describe '#submit_charge' do
    subject { service.submit_charge }

    include_examples 'creates a log event', :submitted_charge
  end

  describe '#resend_confirmation' do
    subject { service.resend_confirmation }

    include_examples 'creates a log event for web orders only',
                     :resent_confirmation
  end

  describe '#resend_items' do
    subject { service.resend_items }

    include_examples 'creates a log event for web orders only', :resent_items
  end

  describe '#send_pay_reminder' do
    subject { service.send_pay_reminder }

    include_examples 'creates a log event for web orders only',
                     :sent_pay_reminder
  end

  describe '#update_ticket_types' do
    subject { service.update_ticket_types(tickets) }

    let(:tickets) { order.tickets }

    include_examples 'creates a log event', :updated_ticket_types do
      let(:info) { { count: order.tickets.count } }
    end

    context 'without any tickets provided' do
      let(:tickets) { [] }

      include_examples 'does not create a log event'
    end
  end

  describe '#cancel_tickets' do
    subject { service.cancel_tickets(order.tickets, reason: reason) }

    let(:reason) { 'foooo' }

    include_examples 'creates a log event', :cancelled_tickets do
      let(:info) { { count: order.tickets.count, reason: reason } }
    end
  end

  describe '#transfer_tickets' do
    subject { service.transfer_tickets(order.tickets) }

    include_examples 'creates a log event', :transferred_tickets do
      let(:info) { { count: order.tickets.count } }
    end
  end

  describe '#enable_resale_for_tickets' do
    subject { service.enable_resale_for_tickets(order.tickets) }

    include_examples 'creates a log event', :enabled_resale_for_tickets do
      let(:info) { { count: order.tickets.count } }
    end
  end
end
