# frozen_string_literal: true

module Ticketing
  class EventsController < BaseController
    before_action :find_event, only: %i[show edit update]
    before_action :prepare_new, only: %i[new create]
    before_action :find_galleries, only: %i[new edit update]

    def index
      @events = authorize(events_scope.ordered_by_dates(:desc))
    end

    def show; end

    def new; end

    def edit; end

    def create
      return render :new unless @event.update(event_params)

      redirect_to @event, notice: t('.created')
    end

    def update
      return render :edit unless @event.update(event_params)

      redirect_to @event, notice: t('.updated')
    end

    private

    def find_event
      @event = authorize(events_scope.find(params[:id]))
    end

    def prepare_new
      @event = authorize(Event.new)
    end

    def find_galleries
      @galleries = Gallery.order(title: :asc)
    end

    def event_params
      event_params = permitted_attributes @event
      event_params[:info][:archived] = event_params[:info][:archived] == '1'
      event_params[:info][:colors] = nil if event_params[:info].fetch(:colors, []).uniq.count == 1
      event_params
    end

    def events_scope
      Event.including_ticketing_disabled
    end
  end
end
