# frozen_string_literal: true

class OrdersController < ApplicationController
  skip_authorization

  before_action :find_records

  WALLET_PATTERN = /(Android|iP(hone|ad|od)|OS X|Windows Phone)/

  helper Ticketing::TicketingHelper

  def show
    refundable_sum = refundable_tickets.sum(&:price)
    balance_after_refund = @order.balance + refundable_sum
    @order_refundable = @order.is_a?(Ticketing::Web::Order) && balance_after_refund.positive?
    @valid_tickets = valid_tickets
  end

  def check_email
    return redirect_to authenticated_overview_path if email_correct?

    redirect_to request.path, alert: t('.wrong_email')
  end

  def passbook_pass
    return head :forbidden if @ticket.blank?

    send_file @ticket.passbook_pass(create: true).file_path,
              type: 'application/vnd.apple.pkpass'
  end

  def seats
    render json: seats_hash
  end

  def refund
    if web_order? && @order.charge_payment? &&
       params[:use_bank_charge] == 'true'
      bank_details = @order.bank_charge.slice(:name, :iban)

    else
      if params[:name].blank? || !IBANTools::IBAN.valid?(params[:iban])
        flash.alert = t('.incorrect_bank_details')
        return redirect_to order_overview_path(params[:signed_info])
      end
      bank_details = params.permit(:name, :iban).to_h
    end

    bank_details[:iban].delete!(' ')

    Ticketing::TicketCancelService.new(refundable_tickets, reason: :date_cancelled)
                                  .execute(send_customer_email: false)

    mailer = Ticketing::RefundMailer.with(order: @order,
                                          **bank_details.symbolize_keys)
    mailer.customer.deliver_later
    mailer.internal.deliver_later

    redirect_to order_overview_path(params[:signed_info]),
                notice: t('.refund_requested')
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

  def valid_tickets
    @order.tickets.valid
  end

  def refundable_tickets
    valid_tickets.filter(&:refundable?)
  end

  def seats_hash
    types = [[:chosen, @order], [:taken, @order.date]]
    types.each_with_object({}) do |type, obj|
      obj[type.first] = type.last.tickets.where(invalidated: false)
                            .filter_map(&:seat_id)
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
