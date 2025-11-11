# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Ticketing::Customer::OrdersController' do
  describe 'GET #show' do
    subject { get customer_order_overview_path(signed_info), headers: }

    let(:order) { create(:web_order, :with_tickets) }
    let(:signed_info) { authenticated_signed_info }
    let(:headers) { nil }

    shared_context 'with a device supporting Apple Wallet' do
      let(:headers) { { 'User-Agent' => 'iPhone' } }
    end

    shared_examples 'does not show wallet download buttons' do
      it 'does not show wallet download buttons' do
        subject
        expect(response.body).not_to include('add_to_wallet')
        expect(response.body).not_to match(%r{/tickets/.+/wallet})
      end
    end

    context 'when signed info is missing' do
      let(:signed_info) { 'foo' }

      it 'redirects to root' do
        subject
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when signed info is unauthenticated' do
      let(:signed_info) { order.signed_info }

      it 'renders the email form' do
        subject
        expect(response.body).to include('E-Mail-Adresse ein, mit der diese Bestellung aufgegeben wurde')
      end
    end

    context 'with a paid order' do
      it_behaves_like 'does not show wallet download buttons'

      context 'with a device supporting Apple Wallet' do
        include_context 'with a device supporting Apple Wallet'

        it 'shows wallet download buttons' do
          subject
          expect(response.body).to include('add_to_wallet')
          expect(response.body).to match(%r{/tickets/.+/wallet})
        end
      end
    end

    context 'with an unpaid order' do
      let(:order) { create(:web_order, :with_tickets, :unpaid) }

      context 'with a device supporting Apple Wallet' do
        include_context 'with a device supporting Apple Wallet'
        it_behaves_like 'does not show wallet download buttons'
      end
    end
  end
end
