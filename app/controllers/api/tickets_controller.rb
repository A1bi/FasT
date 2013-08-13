class Api::TicketsController < ApplicationController
  def check_in
    response = { ok: false }
    ticket = Ticketing::Ticket.where(number: params[:number]).first
    box_office = Ticketing::BoxOffice::Checkpoint.find(params[:checkpoint])
    
    if ticket && box_office
      if params[:in]
        if ticket.can_check_in?
          response[:ok] = true
        else
          response[:error] = :checked_in if ticket.checked_in?
        end
      else
        if ticket.checked_in?
          response[:ok] = true
        else
          response[:error] = :not_checked_in
        end
      end
      ticket.checkins.create(checkpoint: box_office, in: params[:in], medium: params[:medium]) if response[:ok]
    end
    
    render json: response
  end
end