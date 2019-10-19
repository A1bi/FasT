module Api
  module Ticketing
    module BoxOffice
      class TransactionsController < BaseController
        def index
          render json: {
            products: products,
            billings: transactions,
            balance: billing_account.balance
          }
        end

        def create
          billing_account.deposit(params[:amount], params[:reason])
          return head :ok if billing_account.save

          head :unprocessable_entity
        end

        private

        def transactions
          billing_account
            .transfers
            .where('created_at > ?', start_date)
            .map do |transfer|
            {
              reason: translated_note_key(transfer),
              amount: transfer.amount,
              date: transfer.created_at.to_i
            }
          end
        end

        def products
          current_box_office
            .purchases
            .where('ticketing_box_office_purchases.created_at > ?', start_date)
            .includes(:items)
            .where('ticketing_box_office_purchase_items.purchasable_type =
              \'Ticketing::BoxOffice::Product\'')
            .group('ticketing_box_office_purchase_items.purchasable_id')
            .sum('ticketing_box_office_purchase_items.number')
            .map do |item_id, number|
            {
              name: ::Ticketing::BoxOffice::Product.find(item_id).name,
              number: number
            }
          end
        end

        def billing_account
          current_box_office.billing_account
        end

        def start_date
          12.hours.ago
        end

        def translated_note_key(transfer)
          return '' if transfer.note_key.blank?

          t("ticketing.orders.balancing.#{transfer.note_key}",
            default: transfer.note_key.to_s)
        end
      end
    end
  end
end
