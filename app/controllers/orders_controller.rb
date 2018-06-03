class OrdersController < ApplicationController
  before_action :find_records

  def show
    @show_wallet = request.user_agent.match(/(Android|iP(hone|ad|od)|OS X|Windows Phone)/).present?
  end

  def check_email
    if @order.is_a?(Ticketing::Web::Order) && @order.email.present? && @order.email == params[:email]
      redirect_to order_overview_path(@order.signed_info(authenticated: true))
    else
      redirect_to request.path, alert: t("orders.overview.wrong_email")
    end
  end

  def passbook_pass
    if @ticket
      @ticket.create_passbook_pass
      send_file @ticket.passbook_pass.path(true), type: "application/vnd.apple.pkpass"
    else
      head 403
    end
  end

  private

  def find_records
    info = Ticketing::SigningKey.verify_info(params[:signed_info])

    if info.ticket?
      @ticket = Ticketing::Ticket.find(info.ticket.id)
      @order = @ticket.order
    elsif info.order?
      @order = Ticketing::Order.find(info.order.id)
    else
      return redirect_to root_url
    end

    @authenticated = info.authenticated.nonzero? || !@order.is_a?(Ticketing::Web::Order)
  end
end
