module Ticketing
  class PaymentsController < BaseController
    cache_sweeper :order_sweeper, only: [:mark_as_paid, :send_pay_reminder, :approve]
    
    before_filter :find_orders, only: [:mark_as_paid, :approve]
    before_filter :find_unsubmitted_charges, only: [:index, :submit]
    after_filter :sweep_orders_cache, only: [:mark_as_paid, :approve]
    
    def index
      types = [
        [:unpaid, [
          ["where", ["ticketing_bunches.paid IS NULL OR ticketing_bunches.paid = ?", false]]
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
      submission = BankSubmission.new
      submission.charges = @charges
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
      @charges = BankCharge.where(submission_id: nil)
    end
    
    def redirect_to_overview(notice = nil)
      flash[:notice] = t(notice, scope: [:ticketing, :payments]) if notice
      redirect_to ticketing_payments_path
    end
    
    def sweep_orders_cache
      expire_fragment [:ticketing, :orders, :index]
      @orders.each { |order| expire_fragment [:ticketing, :orders, :show, order.bunch.id] }
    end
  end
end