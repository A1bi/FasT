class InfoController < ApplicationController

  require 'open-uri'

  def index
    if params[:event_slug].present?
      @event = Ticketing::Event.current.find_by!(slug: params[:event_slug])
    else
      @event = Ticketing::Event.with_future_dates.first
      return redirect_to event_slug: @event.slug
    end

    template = "index_#{@event.identifier}"
    if template_exists?("info/#{template}")
      render template
    else
      redirect_to action: :index
    end
  end

  def map
    return if params[:identifier].blank?
    template = "map_#{params[:identifier]}"
    render template if template_exists?("info/#{template}")
  end

  def weather
    render json: (Rails.cache.fetch([:info, :weather], expires_in: 30.minutes) do

      api_key = "63fa222741909726"
      api_url = "http://api.wunderground.com/api/" + api_key + "/conditions/forecast/q/Germany/Kaisersesch.json"

      data = JSON.parse(open(api_url).read, symbolize_names: true)

      if data[:error].nil?
        simple_forecast = data[:forecast][:simpleforecast][:forecastday][0]

        weather = {
          temp: data[:current_observation][:temp_c].floor,
          low: simple_forecast[:low][:celsius],
          high: simple_forecast[:high][:celsius],
          pop: data[:forecast][:txt_forecast][:forecastday][0][:pop],
          icon: simple_forecast[:icon],
          date: Time.parse(data[:current_observation][:observation_time_rfc822]).to_s(:time)
        }
      end

      {
        data: weather
      }.to_json

    end)
  end
end
