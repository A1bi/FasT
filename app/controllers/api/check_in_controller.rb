class Api::CheckInController < ApplicationController
  def index
    response = {}

    signing_keys = Ticketing::SigningKey.where(active: true)
    response[:signing_keys] = signing_keys.map do |key|
      { id: key.id, secret: key.secret }
    end

    dates = Ticketing::Event.current.dates
    response[:dates] = dates.map do |date|
      { id: date.id, date: date.date.to_i }
    end

    tickets = Ticketing::Ticket.where(date: dates).where("created_at != updated_at")
    response[:changed_tickets] = tickets.map do |ticket|
      {
        id: ticket.id,
        date_id: ticket.date_id,
        number: ticket.number,
        type_id: ticket.type_id,
        seat_id: ticket.seat_id,
        cancelled: ticket.cancelled?
      }
    end

    render json: response
  end

  def create
    params[:check_ins].each do |check_in|
      ticket = Ticketing::Ticket.find(check_in[:ticket_id])
      ticket.check_ins.create({
        date: Time.at(check_in[:date]),
        medium: check_in[:medium]
      })
    end

    render json: { ok: true }
  end
end
