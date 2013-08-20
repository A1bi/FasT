module Ticketing
  class PaymentsController < BaseController
    before_filter :find_orders, only: [:mark_as_paid, :approve]
    before_filter :find_unsubmitted_charges, only: [:index, :submit]
    
    @@submissions_scope = [:ticketing, :payments, :submissions]
    
    def index
      types = [
        [:unpaid, [
          ["where", ["pay_method = 'transfer' AND (ticketing_bunches.paid IS NULL OR ticketing_bunches.paid = ?)", false]]
        ]],
        [:unapproved, [
          ["includes", "bank_charge"],
          ["where", ["pay_method = 'charge'"]],
          ["where", ["ticketing_bank_charges.approved = ?", false]]
        ]]
      ]
      @orders = {}
      types.each do |type|
        @orders[type[0]] = Web::Order
          .includes(bunch: [:tickets])
          .where(ticketing_tickets: { cancellation_id: nil })
          .order("ticketing_web_orders.created_at DESC")
        type[1].each do |additional|
          @orders[type[0]] = @orders[type[0]].send(additional[0], additional[1])
        end
      end
      
      @submissions = BankSubmission.order("created_at DESC")
    end
    
    def mark_as_paid
      @orders.each { |order| order.mark_as_paid }
      redirect_to_overview(:marked_as_paid)
    end
    
    def approve
      @orders.each { |order| order.approve }
      redirect_to_overview(:approved)
    end
    
    def submit
      return redirect_to_overview(:nothing_submitted) if @unsubmitted_charges.empty?
      
      submission = BankSubmission.new
      submission.charges = @unsubmitted_charges
      submission.save
      
      dta = init_dta(submission)
      BankMailer.submission(dta).deliver
      
      redirect_to_overview(:submitted)
    end
    
    def sheet
      pdf = Rails.cache.fetch([:ticketing, :payments, :sheets, params[:id]], expires_in: 15.minutes) do
        submission = BankSubmission.find(params[:id])
        init_dta(submission).sheet.render
      end
      send_data pdf, disposition: "inline", filename: "#{t(:sheet_file_name, scope: @@submissions_scope)}.pdf", type: "application/pdf"
    end
    
    private
    
    def find_orders
      @orders = []
      (params[:orders] ||= []).each do |orderId|
        @orders << Web::Order.find(orderId)
      end
    end
    
    def find_unsubmitted_charges
      @unsubmitted_charges = BankCharge.where(submission_id: nil, approved: true)
    end
    
    def init_dta(submission)
      dta = DTAUS::ChargeCollection.new(t(:sender, scope: @@submissions_scope), submission.id)
      submission.charges.each do |charge|
        recipient = { name: charge.name, account: charge.number, blz: charge.blz }
        reason = t(:reason, scope: @@submissions_scope, number: charge.chargeable.bunch.number)
        dta.transactions << DTAUS::Transactions::Charge.new(charge.chargeable.bunch.total, recipient, reason)
      end
      dta
    end
    
    def redirect_to_overview(notice = nil)
      flash[:notice] = t(notice, scope: [:ticketing, :payments]) if notice
      redirect_to ticketing_payments_path
    end
  end
end