module Ticketing
  class CouponsController < BaseController
    before_filter :find_coupon, only: [:edit, :update, :show, :destroy, :mail]
    before_filter :prepare_vars, only: [:edit, :new, :update, :create]
    
    def index
      @coupons = Coupon.expired(false).order(:recipient)
      @coupons_expired = Coupon.expired(true).order(:recipient)
    end
    
    def show
      @members = Members::Member.where("email != ''").order(:last_name)
    end
    
    def new
      @coupon = Coupon.new
    end
    
    def create
      @coupon = Coupon.create(coupon_params)
      update_ticket_types
      redirect_to @coupon
    end
    
    def update
      params[:ticketing_coupon][:reservation_group_ids] ||= []
      @coupon.update_attributes(coupon_params)
      @coupon.log(:edited)
      update_ticket_types
      redirect_to @coupon
    end
    
    def destroy
      @coupon.destroy
      redirect_to ticketing_coupons_path
    end
    
    def mail
      (session[:coupon_sending] ||= {})[:subject] = params[:subject]
      session[:coupon_sending][:text] = params[:text]
      
      if ((params[:member] || {})[:id]).present?
        member = Members::Member.find(params[:member][:id])
        params[:email] = member.email
        params[:recipient] = member.nickname
        
        if params[:member_is_recipient].present?
          @coupon.recipient = member.full_name
          @coupon.save
        end
      end
      
      params[:text] = params[:text].gsub("%%recipient%%", params[:recipient]).gsub("%%code%%", @coupon.code) if params[:text].present?
      BaseMailer.mail(to: params[:email], subject: params[:subject], body: params[:text]).deliver
      
      @coupon.log(:sent, email: params[:email], recipient: params[:recipient])
      
      flash[:notice] = t(:sent, scope: [:ticketing, :coupons])
      redirect_to @coupon
    end
    
    private
    
    def find_coupon
      @coupon = Coupon.find(params[:id])
    end
    
    def prepare_vars
      @ticket_types = Ticketing::TicketType.all
      @reservation_groups = Ticketing::ReservationGroup.all
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
    
    def coupon_params
      params.require(:ticketing_coupon).permit(:expires, :recipient, reservation_group_ids: [])
    end
  end
end