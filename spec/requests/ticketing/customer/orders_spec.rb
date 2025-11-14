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

  describe 'GET #tickets' do
    subject do
      get customer_order_overview_tickets_path(authenticated_signed_info, id: ticket_id, format:)
      response
    end

    let(:order) { create(:web_order, :with_tickets, tickets_count: 2) }
    let(:format) { :pdf }
    let(:pdf) { instance_double(Ticketing::TicketsWebPdf, add_tickets: true, render: 'foopdf') }

    before { allow(Ticketing::TicketsWebPdf).to receive(:new).and_return(pdf) }

    context 'with an invalid ticket id' do
      let(:ticket_id) { '999' }

      it { is_expected.to have_http_status(:not_found) }
    end

    context 'with a valid ticket id' do
      let(:ticket) { order.tickets[0] }
      let(:ticket_id) { ticket.id }

      it 'renders the ticket PDF' do
        expect(pdf).to receive(:add_tickets) do |tickets|
          expect(tickets).to contain_exactly(ticket)
        end
        expect(subject.content_type).to eq('application/pdf')
      end

      context 'when requesting a wallet pass' do
        let(:format) { :pkpass }
        let(:pass) { instance_double(Passbook::Pass) }

        before do
          ticket.create_passbook_pass
          allow(Passbook::Pass).to receive(:new).and_return(pass)
          allow(pass).to receive(:save) do
            path = Passbook.destination_path
            FileUtils.mkdir_p(path)
            FileUtils.touch("#{path}/#{ticket.passbook_pass.filename}")
          end
        end

        it 'returns a wallet pass' do
          expect(pass).to receive(:save)
          expect(subject.content_type).to eq('application/vnd.apple.pkpass')
        end
      end

      context 'with an unpaid order' do
        let(:order) { create(:web_order, :with_tickets, :unpaid) }

        it { is_expected.to have_http_status(:forbidden) }
      end

      context 'when the ticket is cancelled' do
        before { ticket.update(cancellation: build(:cancellation)) }

        it { is_expected.to have_http_status(:not_found) }
      end
    end

    context 'with no ticket id' do
      let(:ticket_id) { nil }

      it 'renders the ticket PDF for all tickets' do
        expect(pdf).to receive(:add_tickets) do |tickets|
          expect(tickets).to match_array(order.tickets)
        end
        expect(subject.content_type).to eq('application/pdf')
      end

      context 'when requesting a wallet pass bundle' do
        let(:format) { :pkpasses }
        let(:passes) { order.tickets.map { instance_double(Passbook::Pass) } }

        before do
          allow(Passbook::Pass).to receive(:new).and_return(*passes)
          order.tickets.each.with_index do |ticket, i|
            ticket.create_passbook_pass
            allow(passes[i]).to receive(:save) do
              path = Passbook.destination_path
              FileUtils.mkdir_p(path)
              FileUtils.touch("#{path}/#{ticket.passbook_pass.filename}")
            end
          end
        end

        it 'returns a wallet pass bundle' do
          expect(passes).to all(receive(:save))
          expect(subject.content_type).to eq('application/vnd.apple.pkpasses')
        end
      end
    end
  end
end
