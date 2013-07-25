module Ticketing
  class CouponsController < BaseController
    before_filter :find_coupon, only: [:edit, :update, :show, :destroy]
    before_filter :prepare_vars, only: [:edit, :new, :update, :create]
    
    def index
      @coupons = Coupon.scoped
    end
    
    def new
      @coupon = Coupon.new
    end
    
    def create
      @coupon = Coupon.create(params[:ticketing_coupon])
      update_ticket_types
      redirect_to @coupon
    end
    
    def update
      params[:ticketing_coupon][:reservation_group_ids] ||= []
      @coupon.update_attributes(params[:ticketing_coupon])
      update_ticket_types
      redirect_to @coupon
    end
    
    def destroy
      @coupon.destroy
      redirect_to ticketing_coupons_path
    end
    
    private
    
    def find_coupon
      @coupon = Coupon.find(params[:id])
    end
    
    def prepare_vars
      @ticket_types = Ticketing::TicketType.exclusive.scoped
      @reservation_groups = Ticketing::ReservationGroup.scoped
    end
    
    def update_ticket_types
      @ticket_types.each do |type|
        p = params[:ticket_types][type.id.to_s] || {}
        next if !p
        
        assignment = @coupon.ticket_type_assignments.where(ticket_type_id: type.id).first_or_initialize
        if !p[:enabled].blank?
          assignment.number = p[:number].blank? ? -1 : p[:number]
          assignment.save
        elsif !assignment.new_record?
          assignment.destroy
        end
      end
    end
  end
end