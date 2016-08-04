class OrdersController < ApplicationController
  before_action :find_records

  def show
    @show_wallet = request.user_agent.match(/(Android|iP(hone|ad|od)|OS X|Windows Phone)/).present?
  end

  def check_email
    if @order.is_a?(Ticketing::Web::Order) && @order.email.present? && @order.email == params[:email]
      redirect_to order_overview_path(@order.signed_info(true))
    else
      redirect_to request.path, alert: t("orders.overview.wrong_email")
    end
  end

  def passbook_pass
    if @ticket
      @ticket.create_passbook_pass
      send_file @ticket.passbook_pass.path(true), type: "application/vnd.apple.pkpass"
    else
      render nothing: true, status: 403
    end
  end

  private

  def find_records
    data = Ticketing::SigningKey.verify(params[:signed_info])
    if data[:ti].present?
      @ticket = Ticketing::Ticket.find(data[:ti])
      @order = @ticket.order
      @authorized = !@ticket.order.is_a?(Ticketing::Web::Order)
    elsif data[:or].present?
      @order = Ticketing::Order.find(data[:or])
      @authorized = data[:au].present? || !@order.is_a?(Ticketing::Web::Order)
    else
      redirect_to root_url
    end
  end
end
