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
      session[:coupon_sending] = {
        subject: params[:subject],
        text: params[:text]
      }

      recipient = params[:recipient]
      email = params[:email]

      if params.dig(:member, :id).present?
        member = Members::Member.find(params[:member][:id])
        recipient = member.full_name
        email = member.email
        @coupon.update(recipient: recipient) if params[:member_is_recipient].present?
      end

      Ticketing::CouponsMailer.coupon(@coupon,
                                      email: email,
                                      recipient: recipient,
                                      subject: params[:subject],
                                      body: params[:text]).deliver_later

      @coupon.log(:sent, email: email, recipient: recipient).save

      flash[:notice] = t(:sent, scope: %i[ticketing coupons])
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
