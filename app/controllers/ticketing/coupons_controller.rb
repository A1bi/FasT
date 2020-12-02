# frozen_string_literal: true

module Ticketing
  class CouponsController < BaseController
    before_action :find_coupon, only: %i[edit update show destroy mail]
    before_action :find_reservation_groups, only: %i[edit new update create]

    def index
      authorize Coupon
      coupon_scope = Coupon.where('created_at > ?', 18.months.ago)
                           .where(purchased_with_order: nil)
                           .order(:recipient)
      @coupons = coupon_scope.valid
      @coupons_expired = coupon_scope.expired
    end

    def show
      @members = Members::Member.where("email != ''").order(:last_name)
    end

    def new
      @coupon = authorize Coupon.new
    end

    def create
      @coupon = authorize Coupon.new(coupon_params)
      @coupon.save
      redirect_to @coupon
    end

    def edit; end

    def update
      params[:ticketing_coupon][:reservation_group_ids] ||= []
      @coupon.log(:edited)
      @coupon.update(coupon_params)
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
        recipient = member.name.full
        email = member.email
        if params[:member_is_recipient].present?
          @coupon.update(recipient: recipient)
        end
      end

      Ticketing::CouponsMailer.coupon(@coupon,
                                      email: email,
                                      recipient: recipient,
                                      subject: params[:subject],
                                      body: params[:text]).deliver_later

      @coupon.log(:sent, email: email, recipient: recipient).save

      redirect_to @coupon, notice: t('.sent')
    end

    private

    def find_coupon
      @coupon = authorize Coupon.find(params[:id])
    end

    def find_reservation_groups
      @reservation_groups = Ticketing::ReservationGroup.all
    end

    def coupon_params
      permitted_attributes(@coupon)
    end
  end
end
