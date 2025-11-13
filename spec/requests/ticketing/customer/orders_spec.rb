# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Ticketing::Customer::OrdersController' do
  describe 'GET #show' do
    subject do
      get(customer_order_overview_path(signed_info), headers:)
      response
    end

    let(:order) { create(:web_order, :with_tickets) }
    let(:ticket_ids) { order.tickets.pluck(:id) }
    let(:signed_info) { authenticated_signed_info }
    let(:headers) { nil }
    let(:pdf_paths) { ticket_ids.map { |id| "tickets/#{id}.pdf" } }
    let(:wallet_paths) { ticket_ids.map { |id| "tickets/#{id}.pkpass" } }

    shared_context 'with a device supporting Apple Wallet' do
      let(:headers) { { 'User-Agent' => 'iPhone' } }
    end

    shared_examples 'does not show wallet download buttons' do
      it 'does not show wallet download buttons' do
        expect(subject.body).not_to include('add_to_wallet', *wallet_paths)
      end
    end

    shared_examples 'does not show PDF download buttons' do
      it 'does not show PDF download buttons' do
        expect(subject.body).not_to include('file-earmark-arrow-down-fill', *pdf_paths)
      end
    end

    context 'when signed info is missing' do
      let(:signed_info) { 'foo' }

      it 'redirects to root' do
        expect(subject).to redirect_to(root_url)
      end
    end

    context 'when signed info is unauthenticated' do
      let(:signed_info) { order.signed_info }

      it 'renders the email form' do
        expect(subject.body).to include('E-Mail-Adresse ein, mit der diese Bestellung aufgegeben wurde')
      end
    end

    context 'with a paid order' do
      it 'shows wallet download buttons' do
        expect(subject.body).to include('file-earmark-arrow-down-fill', *pdf_paths)
      end

      it_behaves_like 'does not show wallet download buttons'

      context 'with a device supporting Apple Wallet' do
        include_context 'with a device supporting Apple Wallet'

        it 'shows wallet download buttons' do
          expect(subject.body).to include('add_to_wallet', *wallet_paths)
        end
      end
    end

    context 'with an unpaid order' do
      let(:order) { create(:web_order, :with_tickets, :unpaid) }

      before { order.billing_account.update(balance: -14.52) }

      it 'shows the outstanding amount' do
        expect(subject.body).to include('bezahlt</dt><dd>nein', 'offener Betrag', '14,52 €')
      end

      it_behaves_like 'does not show PDF download buttons'

      context 'with a device supporting Apple Wallet' do
        include_context 'with a device supporting Apple Wallet'
        it_behaves_like 'does not show wallet download buttons'
      end
    end
  end
end
