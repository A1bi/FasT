# frozen_string_literal: true

module Ticketing
  class PaymentsController < BaseController
    before_action :find_orders, only: %i[mark_as_paid]
    before_action :find_transactions_to_submit, only: %i[index submit_transactions]

    def index
      authorize Ticketing::Order, :mark_as_paid?

      @orders = {
        unpaid: {
          transfer: find_unpaid_orders.transfer_payment,
          cash: find_unpaid_orders.cash_payment,
          box_office: find_unpaid_orders.box_office_payment,
          other: find_unpaid_orders(web: false).where.not(
            pay_method: %i[transfer cash box_office]
          )
        },
        credit: orders_with_credit
      }

      @bank_submissions = BankSubmission.order(created_at: :desc).limit(10)
    end

    def mark_as_paid
      @orders.each do |order|
        payment_service(authorize(order)).mark_as_paid
      end
      redirect_to_overview(:marked_as_paid)
    end

    def submit_transactions
      BankSubmission.create(
        transactions: @submittable_transactions.each { |transaction| authorize(transaction, :submit?) }
      )

      redirect_to_overview(:submitted)
    end

    def bank_submission_file
      submission = authorize(BankSubmission.find(params[:id]), :file?)
      service = BankSubmissionFileService.new(submission)
      send_data service.file, filename: service.file_name, type: service.file_type
    end

    private

    def find_orders
      @orders = Web::Order.find(params[:orders])
    end

    def find_transactions_to_submit
      @submittable_transactions = BankTransaction.submittable
    end

    def find_unpaid_orders(web: true)
      klass = web ? Web::Order : Order
      klass.includes(:billing_account).unpaid.order(:number)
    end

    def orders_with_credit
      Order.with_credit.order(:number)
    end

    def payment_service(order)
      OrderPaymentService.new(order, current_user:)
    end

    def redirect_to_overview(notice = nil)
      options = { scope: %i[ticketing payments] }
      options[:count] = @orders.count if @orders
      flash.notice = t(notice, **options) if notice
      redirect_to ticketing_payments_path
    end
  end
end
