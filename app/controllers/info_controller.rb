# frozen_string_literal: true

class InfoController < ApplicationController
  skip_authorization

  def map
    @event = Ticketing::Event.current.find(params[:event_id])
  end

  private

  def page_for_event_exists?
    template_exists?("info/#{template_for_event}")
  end

  def template_for_event
    "index_#{@event.identifier}"
  end
end
