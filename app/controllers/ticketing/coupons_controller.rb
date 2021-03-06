# frozen_string_literal: true

module Ticketing
  class CouponsController < BaseController
    before_action :find_coupon, only: %i[edit update show destroy mail]
    before_action :build_coupon, only: %i[new create]

    def index
      authorize Coupon
      coupon_scope = Coupon.where('ticketing_coupons.created_at > ?',
                                  18.months.ago)
                           .where(purchased_with_order: nil)
                           .order(:recipient)
      @coupons = coupon_scope.valid
      @coupons_expired = coupon_scope.expired
    end

    def show
      @members = Members::Member.where("email != ''").order(:last_name)
      @billing_actions = %i[correction]
    end

    def new; end

    def create
      if @coupon.update(coupon_params)
        @coupon.deposit_into_account(params[:ticketing_coupon][:value].to_f,
                                     :created_coupon)
        log_service.create
      end
      redirect_to @coupon
    end

    def edit; end

    def update
      log_service.update if @coupon.update(coupon_params)
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

      @coupon.log!(:sent, email: email, recipient: recipient)

      redirect_to @coupon, notice: t('.sent')
    end

    private

    def find_coupon
      @coupon = authorize Coupon.find(params[:id])
    end

    def build_coupon
      @coupon = authorize Coupon.new
    end

    def log_service
      @log_service ||=
        LogEventCreateService.new(@coupon, current_user: current_user)
    end

    def coupon_params
      permitted_attributes @coupon
    end
  end
end
