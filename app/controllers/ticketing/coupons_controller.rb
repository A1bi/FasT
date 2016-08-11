module Ticketing
  class CouponsController < BaseController
    before_action :find_coupon, only: [:edit, :update, :show, :destroy, :mail]
    before_action :prepare_vars, only: [:edit, :new, :update, :create]

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
      redirect_to @coupon
    end

    def update
      params[:ticketing_coupon][:reservation_group_ids] ||= []
      @coupon.log(:edited)
      @coupon.update_attributes(coupon_params)
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

      @coupon.log(:sent, email: params[:email], recipient: params[:recipient]).save

      flash[:notice] = t(:sent, scope: [:ticketing, :coupons])
      redirect_to @coupon
    end

    private

    def find_coupon
      @coupon = Coupon.find(params[:id])
    end

    def prepare_vars
      @reservation_groups = Ticketing::ReservationGroup.all
    end

    def coupon_params
      params.require(:ticketing_coupon).permit(:expires, :recipient, :free_tickets, reservation_group_ids: [])
    end
  end
end
