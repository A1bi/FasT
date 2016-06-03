class OrdersController < ApplicationController
  before_action :find_ticket
  
  def passbook_pass
    if @ticket
      @ticket.create_passbook_pass
      send_file @ticket.passbook_pass.path(true), type: "application/vnd.apple.pkpass"
    else
      render nothing: true, status: 403
    end
  end
  
  private
  
  def find_ticket
    @ticket = Ticketing::Ticket.find_by_urlsafe_signed_info(params[:signed_info])
  end
end