# frozen_string_literal: true

module Ticketing
  class PaymentsController < BaseController
    before_action :find_orders, only: %i[mark_as_paid]
    before_action :find_charges_to_submit, only: %i[index submit_charges]
    before_action :find_refunds_to_submit, only: %i[index submit_refunds]

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

      @charge_submissions = BankChargeSubmission.order(created_at: :desc).limit(10)
      @refund_submissions = BankRefundSubmission.order(created_at: :desc).limit(10)
    end

    def mark_as_paid
      @orders.each do |order|
        payment_service(authorize(order)).mark_as_paid
      end
      redirect_to_overview(:marked_as_paid)
    end

    def submit_charges
      @unsubmitted_charges.each { |order| authorize(order.bank_charge, :submit?) }

      DebitSubmitService.new(@unsubmitted_charges, current_user:).execute

      redirect_to_overview(:submitted)
    end

    def submit_refunds
      @unsubmitted_refunds.each { |order| authorize(order.bank_refunds.last, :submit?) }

      RefundSubmitService.new(@unsubmitted_refunds, current_user:).execute

      redirect_to_overview(:submitted)
    end

    def charge_submission_file
      service = DebitSepaXmlService.new(submission_id: params[:id])
      authorize service.submission, :submission_file?
      send_data service.xml, filename: "sepa-#{service.submission.id}.xml", type: 'application/xml'
    end

    def refund_submission_file
      service = RefundSepaXmlService.new(submission_id: params[:id])
      authorize service.submission, :submission_file?
      send_data service.xml, filename: "sepa-#{service.submission.id}.xml", type: 'application/xml'
    end

    private

    def find_orders
      @orders = Web::Order.find(params[:orders])
    end

    def find_charges_to_submit
      @unsubmitted_charges = Web::Order.charges_to_submit
    end

    def find_refunds_to_submit
      @unsubmitted_refunds = Web::Order.refunds_to_submit
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
      flash[:notice] = t(notice, **options) if notice
      redirect_to ticketing_payments_path
    end
  end
end
