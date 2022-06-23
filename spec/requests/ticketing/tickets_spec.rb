# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Ticketing::TicketsController' do
  describe 'PATCH #cancel' do
    subject { patch cancel_ticketing_order_tickets_path(params) }

    let(:params) { { order_id: order.id, ticket_ids: } }
    let(:ticket_ids) { [*order.tickets[1..2].pluck(:id), order2.tickets.first.id] }

    before do
      sign_in(user:)

      pdf = Ticketing::TicketsRetailPdf.new
      allow(Ticketing::TicketsRetailPdf).to receive(:new).and_return(pdf)
      allow(pdf).to receive(:add_tickets)
      allow(pdf).to receive(:render_file)

      order.tickets.update_all(price: 10) # rubocop:disable Rails/SkipsModelValidations
      order.billing_account.update(balance: 20)
      order.update(total: 30)
    end

    shared_examples 'general cancellation' do
      it 'cancels the provided tickets' do
        expect { subject }.to(change { order.tickets.reload.map(&:cancelled?) }.to([false, true, true]))
      end

      it 'does not cancel the not provided ticket' do
        expect { subject }.not_to(change { order.tickets.first.reload.cancelled? })
      end

      it 'does not cancel the provided ticket from another order' do
        expect { subject }.not_to(change { order2.tickets.first.reload.cancelled? })
      end

      it 'changes the order balance' do
        expect { subject }.to(change { order.billing_account.reload.balance }.to(40))
      end
    end

    context 'with an admin user' do
      let(:user) { build(:user, :admin) }
      let(:order) { create(:order, :with_tickets, tickets_count: 3) }
      let(:order2) { create(:order, :with_tickets, tickets_count: 1) }

      include_examples 'general cancellation'
    end

    context 'with a retail store user' do
      let(:user) { build(:retail_user) }
      let(:order) { create(:retail_order, :with_tickets, tickets_count: 3, store: user.store) }
      let(:order2) { create(:retail_order, :with_tickets, tickets_count: 1, store: user.store) }

      before { user.store.billing_account.update(balance: -100) }

      include_examples 'general cancellation'

      context 'with refund wanted' do
        before { params[:refund] = true }

        it 'transfers the refund from the retail store account' do
          expect { subject }.to(change { user.store.billing_account.reload.balance }.to(-60))
        end

        it 'balances the order billing account' do
          expect { subject }.to(change { order.billing_account.reload.balance }.to(0))
        end
      end

      context 'with refund unwanted' do
        it 'does not transfer any funds' do
          expect { subject }.not_to(change { user.store.billing_account.reload.balance })
        end
      end
    end
  end
end
