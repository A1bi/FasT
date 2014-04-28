class OrdersController < ApplicationController
  before_filter :disable_slides
  before_filter :set_event_info, :only => [:new, :new_retail, :new_service]
  restrict_access_to_group :admin, :only => [:new_service, :enable_reservation_groups]
  
  def new
    @type = :web
  end
  
  def new_retail
    if !session[:retail_id].present? || (params[:store_id].present? && params[:store_id] != session[:retail_id])
      return redirect_to retail_order_login_path(:store_id => params[:store_id]), :flash => { :warning => t("orders.retail_login.required") }
    end
    
    @store = Ticketing::Retail::Store.find(session[:retail_id])
    @type = :retail
  end
  
  def new_service
    @type = :service
    @reservation_groups = Ticketing::ReservationGroup.scoped
  end
  
  def retail_login
    @stores = [Ticketing::Retail::Store.find(params[:store_id] || 3)]
  end
  
  def retail_login_check
    # TODO: remove this insecure bullshit
    if Ticketing::Retail::Store.exists?(params[:store]) && params[:password] == "9z2v*va38.y2Gg#{params[:store]}F"
      session[:retail_id] = params[:store]
      
      redirect_to new_retail_order_path
    else
      redirect_to retail_order_login_path(:store_id => params[:store]), :flash => { :alert => t("orders.retail_login.auth_error") }
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
      
      response[:seats] = set_exclusive_seats(coupon.reservation_groups).any?
      
      response[:ticket_types] = coupon.ticket_type_assignments.map do |assignment|
        { id: assignment.ticket_type.id, number: assignment.number }
      end
    end
    
    render json: response
  end
  
  def enable_reservation_groups
    groups = []
    (params[:groups] ||= []).each do |group_id|
      groups << Ticketing::ReservationGroup.find(group_id)
    end
    
    response = { ok: true, seats: set_exclusive_seats(groups, true).any? }
    
    render json: response
  end
  
  private
  
	def set_event_info
		@event = Ticketing::Event.current
    @dates = @event.dates.where("date > ?", Time.zone.now)
		@seats = Ticketing::Seat.all
		@ticket_types = Ticketing::TicketType.order(:price)
  end
  
  def set_exclusive_seats(groups, even_if_empty = false)
    seats = {}
    (groups).each do |reservation_group|
      reservation_group.reservations.each do |reservation|
        (seats[reservation.date.id] ||= []) << reservation.seat.id
      end
    end
    NodeApi.seating_request("setExclusiveSeats", { clientId: params[:seatingId], seats: seats }) if seats.any? || even_if_empty
    seats
  end
end
