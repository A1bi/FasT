# frozen_string_literal: true

class TheaterController < ApplicationController
  skip_authorization

  before_action :disable_member_controls, except: :index

  def index; end

  def show
    template = if params[:slug].in?(%w[phantasus medicus hexenjagd montevideo])
                 params[:slug]
               else
                 event = Ticketing::Event.find_by!(slug: params[:slug])
                 @dates = event.dates.order(:date)
                 event.identifier
               end
    return head :not_found unless template_exists?("theater/#{template}")

    render template
  end
end
