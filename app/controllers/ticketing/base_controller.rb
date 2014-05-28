class Ticketing::BaseController < ApplicationController
	restrict_access_to_group :admin
	
	before_filter :disable_slides
  before_filter :authenticate_retail_store
  
  def authenticate_retail_store
		begin
			@_retail_store ||= Ticketing::Retail::Store.find(retail_store_id_cookie) if retail_store_id_cookie.present?
		rescue
			delete_retail_store_id_cookie
		end
    @_retail_store ||= Ticketing::Retail::Store.new
  end
  
  protected
  
  def retail_store_id_cookie
    cookies.signed[retail_store_id_cookie_name]
  end
  
  def retail_store_id_cookie=(value)
    cookies.permanent.signed[retail_store_id_cookie_name] = value
  end
  
  def delete_retail_store_id_cookie
    cookies.delete retail_store_id_cookie_name
  end
  
  private
  
  def retail_store_id_cookie_name
    "_#{Rails.application.class.parent_name}_retail_store_id"
  end
  
  def admin?
    params[:type] == :admin
  end
  def retail?
    params[:type] == :retail
  end
  def web?
    !admin? && !retail?
  end
  helper_method :admin?, :retail?, :web?
  
  def orders_path(action, params = nil)
    action = action.to_s.sub("ticketing", "ticketing_retail") if retail?
    send(action.to_s + "_path", params)
  end
  helper_method :orders_path
  
  def update_node_seats_from_tickets(tickets)
    seats = {}
    tickets.each do |ticket|
      seats.deep_merge!({ ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]] })
    end
    NodeApi.update_seats(seats)
  end
end
