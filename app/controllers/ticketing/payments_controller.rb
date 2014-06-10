module Ticketing
  class PaymentsController < BaseController
    before_filter :find_orders, only: [:mark_as_paid, :approve]
    before_filter :find_unsubmitted_charges, only: [:index, :submit]
    
    def index
      @orders = {}
      %i(unpaid unapproved).each do |type|
        @orders[type] = Web::Order.order(:number)
      end
      
      @orders[:unpaid]
        .where!(pay_method: Ticketing::Web::Order.pay_methods[:transfer])
        .where!(paid: false)
      
      @orders[:unapproved]
        .includes!(:bank_charge)
        .where!(pay_method: Ticketing::Web::Order.pay_methods[:charge])
        .where!(ticketing_bank_charges: { approved: false })
      
      @submissions = BankSubmission.order(created_at: :desc)
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
      return redirect_to_overview if @unsubmitted_charges.empty?
      
      submission = BankSubmission.new
      submission.charges = @unsubmitted_charges
      submission.save
      
      redirect_to_overview(:submitted)
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
    
    def redirect_to_overview(notice = nil)
      flash[:notice] = t(notice, scope: [:ticketing, :payments]) if notice
      redirect_to ticketing_payments_path
    end
  end
end