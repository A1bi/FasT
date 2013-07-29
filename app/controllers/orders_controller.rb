class OrdersController < ApplicationController
  before_filter :disable_slides
  before_filter :set_event_info, :only => [:new, :new_retail]
  
  def new_retail
    if !session[:retail_id].present?
      return redirect_to retail_order_login_path, :flash => { :warning => t("orders.retail_login.required") }
    end
    
    @store = Ticketing::Retail::Store.find(session[:retail_id])
  end
  
  def retail_login
    @stores = [Ticketing::Retail::Store.find(3)]
  end
  
  def retail_login_check
    # TODO: remove this insecure bullshit
    if params[:store] == "3" && params[:password] == "9z2v*va38.y2Gg3F"
      session[:retail_id] = params[:store]
      
      redirect_to new_retail_order_path
    else
      redirect_to retail_order_login_path, :flash => { :alert => t("orders.retail_login.auth_error") }
    end
  end
  
  def redeem_coupon
    response = { ok: false }
    coupon = Ticketing::Coupon.where(code: params[:code]).first
    if !coupon
      response[:error] = "not found"
    elsif coupon.expired?
      response[:error] = "expired"
    else
      response[:ok] = true
      
      seats = {}
      (coupon.reservation_groups).each do |reservation_group|
        reservation_group.reservations.each do |reservation|
          (seats[reservation.date.id] ||= []) << reservation.seat.id
        end
      end
      NodeApi.seating_request("setExclusiveSeats", { clientId: params[:seatingId], seats: seats }) if !seats.empty?
      response[:seats] = !seats.empty?
      
      response[:ticket_types] = coupon.ticket_type_assignments.map do |assignment|
        { id: assignment.ticket_type.id, number: assignment.number }
      end
    end
    
    render json: response
  end
  
  private
  
	def set_event_info
		@event = Ticketing::Event.current
		@seats = Ticketing::Seat.scoped
		@ticket_types = Ticketing::TicketType.order(:price)
  end
end
