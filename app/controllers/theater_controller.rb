class TheaterController < ApplicationController
  skip_verify_authorized

  before_action :disable_member_controls, except: :index

  def index; end

  def show
    if params[:slug].in?(%w[phantasus medicus hexenjagd montevideo])
      render params[:slug]

    else
      event = Ticketing::Event.find_by!(slug: params[:slug])
      @dates = event.dates.order(:date)
      render event.identifier
    end
  end
end
