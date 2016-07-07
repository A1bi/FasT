module Ticketing
  class PaymentsController < BaseController
    before_filter :find_orders, only: [:mark_as_paid, :approve]
    before_filter :find_charges_to_submit, only: [:index, :submit]

    def index
      @orders = {
        unpaid:     find_unpaid_orders
                      .where.not(pay_method: Ticketing::Web::Order.pay_methods[:charge]),
        unapproved: find_unsubmitted_charges(false)
      }

      @submissions = BankSubmission.order(created_at: :desc)
    end
    
    def mark_as_paid
      @orders.each do |order|
        order.mark_as_paid
        order.save
      end
      redirect_to_overview(:marked_as_paid)
    end
    
    def approve
      @orders.each do |order|
        order.approve
        order.save
      end
      redirect_to_overview(:approved)
    end
    
    def submit
      return redirect_to_overview if @unsubmitted_charges.empty?
      
      submission = BankSubmission.new
      submission.charges = @unsubmitted_charges.map { |o| o.bank_charge }
      submission.save
      
      redirect_to_overview(:submitted)
    end
    
    def submission_file
      submission = BankSubmission.find(params[:id])
      
      submissions_scope = [:ticketing, :payments, :submissions]
      creditor = Hash[[:name, :iban, :creditor_identifier].map { |key| [key, t(key, scope: submissions_scope)] }]
      debit = SEPA::DirectDebit.new(creditor)
      debit.message_identification = "FasT/#{submission.id}"

      submission.charges.each do |charge|
        debit.add_transaction(
          name: charge.name[0..69],
          iban: charge.iban,
          amount: charge.amount,
          instruction: charge.id,
          remittance_information: t(:remittance_information, scope: submissions_scope, number: charge.chargeable.number),
          mandate_id: charge.mandate_id,
          mandate_date_of_signature: charge.created_at.to_date,
          local_instrument: "COR1",
          sequence_type: "OOFF",
          batch_booking: true,
          requested_date: Date.today + 2
        )
      end
      
      send_data debit.to_xml("pain.008.003.02"), filename: "sepa-#{submission.id}.xml", type: "application/xml"
    end
    
    private
    
    def find_orders
      @orders = []
      (params[:orders] ||= []).each do |orderId|
        @orders << Web::Order.find(orderId)
      end
    end

    def find_charges_to_submit
      @unsubmitted_charges = find_unsubmitted_charges(true)
    end

    def find_unsubmitted_charges(approved)
      find_unpaid_orders.includes(:bank_charge)
        .where(pay_method: Ticketing::Web::Order.pay_methods[:charge])
        .where(ticketing_bank_charges: { approved: approved, submission_id: nil })
    end

    def find_unpaid_orders
      Web::Order.includes(:billing_account).where(paid: false).order(:number)
    end

    def redirect_to_overview(notice = nil)
      options = { scope: [:ticketing, :payments] }
      options[:count] = @orders.count if @orders
      flash[:notice] = t(notice, options) if notice
      redirect_to ticketing_payments_path
    end
  end
end