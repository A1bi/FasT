module Ticketing
  class PaymentsController < BaseController
    before_action :find_orders, only: %i[mark_as_paid approve]
    before_action :find_charges_to_submit, only: %i[index submit]

    def index
      authorize Ticketing::Order, :mark_as_paid?

      @orders = {
        unpaid: {
          transfer: find_unpaid_orders.transfer_payment,
          cash: find_unpaid_orders.cash_payment,
          box_office: find_unpaid_orders.box_office_payment,
          other: find_unpaid_orders(false).where.not(
            pay_method: %i[transfer cash box_office]
          )
        },
        unapproved: Web::Order.charges_to_submit(false),
        outstanding_credit: orders_with_outstanding_credit
      }

      @submissions = BankSubmission.order(created_at: :desc).limit(10)
    end

    def mark_as_paid
      authorize Ticketing::Order

      @orders.each do |order|
        order.mark_as_paid
        order.save
      end
      redirect_to_overview(:marked_as_paid)
    end

    def approve
      authorize Ticketing::BankCharge

      @orders.each do |order|
        order.approve
        order.save
      end
      redirect_to_overview(:approved)
    end

    def submit
      authorize Ticketing::BankCharge

      return redirect_to_overview if @unsubmitted_charges.empty?

      submission = BankSubmission.new
      submission.charges = @unsubmitted_charges.map(&:bank_charge)
      submission.save

      redirect_to_overview(:submitted)
    end

    def submission_file
      service = DebitSepaXmlService.new(submission_id: params[:id])
      authorize service.submission
      send_data service.xml, filename: "sepa-#{service.submission.id}.xml",
                             type: 'application/xml'
    end

    private

    def find_orders
      @orders = Web::Order.find(params[:orders])
    end

    def find_charges_to_submit
      @unsubmitted_charges = Web::Order.charges_to_submit(true)
    end

    def find_unpaid_orders(web = true)
      klass = web ? Web::Order : Order
      klass.includes(:billing_account).unpaid.order(:number)
    end

    def orders_with_outstanding_credit
      Order.joins(:billing_account)
           .where('ticketing_billing_accounts.balance > 0')
           .order(:number)
    end

    def redirect_to_overview(notice = nil)
      options = { scope: %i[ticketing payments] }
      options[:count] = @orders.count if @orders
      flash[:notice] = t(notice, options) if notice
      redirect_to ticketing_payments_path
    end
  end
end
