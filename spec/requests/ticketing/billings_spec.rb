# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Ticketing::BillingsController' do
  describe 'POST #create' do
    subject { post ticketing_billings_path(params) }

    let(:params) { { billable_id:, billable_type:, note: } }
    let(:billable_id) { billable.id }
    let(:billing_service) do
      instance_double(Ticketing::OrderBillingService,
                      settle_balance: nil, refund_in_retail_store: nil, adjust_balance: nil)
    end
    let(:sign_in_user) { sign_in(admin: true) }

    before { sign_in_user }

    context 'with an order' do
      let(:billable) { create(:web_order, :with_purchased_coupons) }
      let(:billable_type) { 'Order' }

      shared_examples 'redirects to order details' do
        it 'redirects to the order details' do
          subject
          expect(response).to redirect_to(ticketing_order_path(billable))
        end
      end

      shared_examples 'does not call billing service' do
        it 'does not call the billing service' do
          %i[settle_balance refund_in_retail_store adjust_balance].each do |msg|
            expect(billing_service).not_to receive(msg)
          end
          subject
        end
      end

      before do
        allow(Ticketing::OrderBillingService).to receive(:new).with(billable).and_return(billing_service)
      end

      context 'with note = transfer_refund' do
        let(:note) { :transfer_refund }

        context 'with an admin user' do
          it 'call the billing service' do
            expect(billing_service).to receive(:settle_balance).with(:transfer_refund)
            subject
          end

          include_examples 'redirects to order details'
        end

        context 'with a retail user' do
          let(:sign_in_user) { sign_in(user: create(:retail_user)) }

          include_examples 'does not call billing service'
        end

        context 'when unauthenticated' do
          let(:sign_in_user) { nil }

          include_examples 'redirect unauthenticated'
        end
      end

      context 'with note = cash_refund_in_store' do
        let(:note) { :cash_refund_in_store }

        shared_examples 'creates the billing' do
          it 'call the billing service' do
            expect(billing_service).to receive(:refund_in_retail_store)
            subject
          end

          include_examples 'redirects to order details'
        end

        context 'with an admin user' do
          include_examples 'creates the billing'
        end

        context 'with a retail user' do
          let(:sign_in_user) { sign_in(user: create(:retail_user)) }

          context 'with a web order' do
            include_examples 'does not call billing service'
            include_examples 'redirect unauthorized'
          end

          context 'with a retail order' do
            let(:billable) { create(:retail_order, :with_purchased_coupons) }

            include_examples 'creates the billing'
          end
        end

        context 'when unauthenticated' do
          let(:sign_in_user) { nil }

          include_examples 'redirect unauthenticated'
        end
      end

      context 'with note = correction' do
        let(:note) { :correction }
        let(:params) { super().merge(amount:) }
        let(:amount) { 20 }

        context 'with an admin user' do
          it 'call the billing service' do
            expect(billing_service).to receive(:adjust_balance).with(amount)
            subject
          end

          include_examples 'redirects to order details'
        end

        context 'with a retail user' do
          let(:sign_in_user) { sign_in(user: create(:retail_user)) }

          include_examples 'does not call billing service'
          include_examples 'redirect unauthorized'
        end

        context 'when unauthenticated' do
          let(:sign_in_user) { nil }

          include_examples 'redirect unauthenticated'
        end
      end
    end

    context 'with a coupon' do
      let(:billable) { create(:coupon) }
      let(:billable_type) { 'Coupon' }

      shared_examples 'redirects to coupon details' do
        it 'redirects to the coupon details' do
          subject
          expect(response).to redirect_to(ticketing_coupon_path(billable))
        end
      end

      context 'with note = correction' do
        let(:note) { :correction }
        let(:params) { super().merge(amount:) }
        let(:amount) { 2 }

        shared_examples 'does not change the balance' do
          it 'does not change the balance' do
            expect { subject }.not_to(change { billable.reload.value })
          end
        end

        context 'with an admin user' do
          it 'changes the balance' do
            expect { subject }.to change { billable.reload.value }.by(2)
          end

          include_examples 'redirects to coupon details'
        end

        context 'with a retail user' do
          let(:sign_in_user) { sign_in(user: create(:retail_user)) }

          include_examples 'does not change the balance'
          include_examples 'redirect unauthorized'
        end

        context 'when unauthenticated' do
          let(:sign_in_user) { nil }

          include_examples 'does not change the balance'
          include_examples 'redirect unauthenticated'
        end
      end
    end

    context 'with an unknown record' do
      let(:billable_id) { 1 }
      let(:billable_type) { 'Foo' }
      let(:note) { :foo }

      it 'results in a 404' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
