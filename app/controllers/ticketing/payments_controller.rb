module Ticketing
  class PaymentsController < BaseController
    before_action :find_orders, only: [:mark_as_paid, :approve]
    before_action :find_charges_to_submit, only: [:index, :submit]

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
      submission.charges = @unsubmitted_charges.map { |o| o.bank_charge }
      submission.save

      redirect_to_overview(:submitted)
    end

    def submission_file
      authorize Ticketing::BankCharge

      submission = BankSubmission.find(params[:id])

      info_keys = %i[name iban creditor_identifier]
      debit_info = Hash[info_keys.map { |key| [key, translate_submission(key)] }]

      debit = SEPA::DirectDebit.new(debit_info)
      debit.message_identification = "FasT/#{submission.id}"

      submission.charges.each do |charge|
        debit.add_transaction(
          name: charge.name[0..69],
          iban: charge.iban,
          amount: charge.amount,
          instruction: charge.id,
          remittance_information: translate_submission(:debit_remittance_information, number: charge.chargeable.number),
          mandate_id: charge.mandate_id,
          mandate_date_of_signature: charge.created_at.to_date,
          local_instrument: "COR1",
          sequence_type: "OOFF",
          batch_booking: true,
          requested_date: Date.today + 2
        )
      end

      send_data debit.to_xml, filename: "sepa-#{submission.id}.xml", type: 'application/xml'
    end

    def credit_transfer_file
      authorize Ticketing::Order

      orders = orders_with_outstanding_credit
      return redirect_to_overview if orders.none?

      require 'csv'

      csv_string = CSV.generate do |csv|
        orders.each do |order|
          row = []
          if order.is_a?(Web::Order)
            if order.charge_payment?
              row << order.bank_charge.name[0..69]
              row << order.bank_charge.iban
            else
              row << "#{order.first_name} #{order.last_name}"
              row << ''
            end
          else
            row += [''] * 2
          end
          row << order.billing_account.balance
          row << translate_submission(:transfer_remittance_information, number: order.number)
          csv << row
        end
      end

      send_data csv_string, filename: 'transfer.csv', type: 'text/csv'
    end

    private

    def find_orders
      @orders = []
      (params[:orders] ||= []).each do |orderId|
        @orders << Web::Order.find(orderId)
      end
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
      options = { scope: [:ticketing, :payments] }
      options[:count] = @orders.count if @orders
      flash[:notice] = t(notice, options) if notice
      redirect_to ticketing_payments_path
    end

    def translate_submission(key, options = {})
      options[:scope] = %i[ticketing payments submissions]
      t(key, options)
    end
  end
end
