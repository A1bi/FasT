# frozen_string_literal: true

class OrdersController < ApplicationController
  skip_authorization

  before_action :find_records

  WALLET_PATTERN = /(Android|iP(hone|ad|od)|OS X|Windows Phone)/.freeze

  def show; end

  def check_email
    return redirect_to authenticated_overview_path if email_correct?

    redirect_to request.path, alert: t('.wrong_email')
  end

  def passbook_pass
    return head 403 if @ticket.blank?

    send_file @ticket.passbook_pass(create: true).file_path,
              type: 'application/vnd.apple.pkpass'
  end

  def seats
    render json: seats_hash
  end

  private

  def find_records
    info = Ticketing::SigningKey.verify_info(params[:signed_info])

    if info.try(:ticket?)
      @ticket = Ticketing::Ticket.find(info.ticket.id)
      @order = @ticket.order
    elsif info.try(:order?)
      @order = Ticketing::Order.find(info.order.id)
    else
      return redirect_to root_url
    end

    @authenticated = info.authenticated.nonzero? || !web_order?
  end

  def seats_hash
    types = [[:chosen, @order], [:taken, @order.date]]
    types.each_with_object({}) do |type, obj|
      obj[type.first] = type.last.tickets.where(invalidated: false)
                            .map(&:seat_id).compact
    end
  end

  def web_order?
    @order.is_a? Ticketing::Web::Order
  end

  def email_correct?
    web_order? && @order.email.present? && @order.email == params[:email]
  end

  def authenticated_overview_path
    order_overview_path(@order.signed_info(authenticated: true))
  end

  def show_wallet?
    @show_wallet ||= request.user_agent.match(WALLET_PATTERN).present?
  end
  helper_method :show_wallet?
end
