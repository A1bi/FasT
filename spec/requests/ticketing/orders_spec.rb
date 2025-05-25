# frozen_string_literal: true

require 'support/authentication'
require_shared_examples 'ticketing/loggable'

RSpec.describe 'Ticketing::OrdersController' do
  let(:order) { create(:web_order, :with_purchased_coupons) }
  let(:loggable) { order }

  before { sign_in(admin: true, web_authn: true) }

  describe 'PATCH #update' do
    subject { patch ticketing_order_path(order), params: }

    let(:params) { { ticketing_order: { first_name: 'John' } } }

    it_behaves_like 'creates a log event', :updated
  end

  describe 'POST #resend_confirmation' do
    subject { post resend_confirmation_ticketing_order_path(order) }

    it 'resends a confirmation' do
      expect { subject }
        .to have_enqueued_mail(Ticketing::OrderMailer, :confirmation)
        .with(a_hash_including(params: { order: }))
    end

    it_behaves_like 'creates a log event', :resent_confirmation
  end

  describe 'POST #resend_items' do
    subject { post resend_items_ticketing_order_path(order) }

    it 'resends an email with the purchased items' do
      expect { subject }
        .to have_enqueued_mail(Ticketing::OrderMailer, :resend_items)
        .with(a_hash_including(params: { order: }))
    end

    it_behaves_like 'creates a log event', :resent_items
  end
end
