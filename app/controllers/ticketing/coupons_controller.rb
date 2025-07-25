# frozen_string_literal: true

module Ticketing
  class CouponsController < BaseController
    before_action :find_coupon, only: %i[edit update show destroy mail]
    before_action :build_coupon, only: %i[new create]

    def index
      authorize Coupon

      @coupons = if params[:q].present?
                   CouponSearchService.new(params[:q], scope: Coupon).execute
                 else
                   Coupon.where(ticketing_coupons: { created_at: 18.months.ago.. },
                                purchased_with_order: nil)
                         .order(recipient: :asc, created_at: :desc)
                 end

      redirect_to ticketing_coupon_path(@coupons.first) if @coupons.one?
    end

    def show
      respond_to do |format|
        format.html do
          @members = Members::Member.where("email != ''").order(:last_name)
          @billing_actions = %i[correction]
        end
        format.pdf do
          pdf = CouponPdf.new(@coupon)
          send_data pdf.render, type: 'application/pdf', disposition: 'inline'
        end
      end
    end

    def new; end

    def edit; end

    def create
      if @coupon.update(coupon_params)
        @coupon.deposit_into_account(params[:ticketing_coupon][:value].to_f,
                                     :created_coupon)
        log_service.create
      end
      redirect_to @coupon
    end

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
        @coupon.update(recipient:) if params[:member_is_recipient].present?
      end

      Ticketing::CouponsMailer.coupon(@coupon,
                                      email:,
                                      recipient:,
                                      subject: params[:subject],
                                      body: params[:text]).deliver_later

      log_service.send(email:, recipient:)

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
      @log_service ||= LogEventCreateService.new(@coupon, current_user:)
    end

    def coupon_params
      permitted_attributes @coupon
    end
  end
end
