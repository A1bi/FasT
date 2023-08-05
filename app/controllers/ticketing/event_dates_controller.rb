# frozen_string_literal: true

module Ticketing
  class EventDatesController < BaseController
    before_action :find_event
    before_action :find_date, only: %i[edit update destroy]
    before_action :prepare_new, only: %i[new create]

    def new; end

    def edit; end

    def create
      render :new unless @date.update(date_params)

      redirect_to @event, notice: t('.created')
    end

    def update
      render :edit unless @date.update(date_params)

      redirect_to @event, notice: t('.updated')
    end

    def destroy
      flash.notice = t('.destroyed') if @date.destroy
      redirect_to @event
    end

    private

    def find_event
      @event = events_scope.find(params[:event_id])
    end

    def find_date
      @date = authorize(@event.dates.find(params[:id]))
    end

    def prepare_new
      @date = authorize(@event.dates.new)
    end

    def date_params
      permitted_attributes @date
    end

    def events_scope
      Event.including_ticketing_disabled
    end
  end
end
