# frozen_string_literal: true

module Ticketing
  class TicketTypesController < BaseController
    before_action :find_event
    before_action :find_type, only: %i[edit update destroy]
    before_action :prepare_new, only: %i[new create]

    def new; end

    def edit; end

    def create
      render :new unless @type.update(date_params)

      redirect_to @event, notice: t('.created')
    end

    def update
      render :edit unless @type.update(date_params)

      redirect_to @event, notice: t('.updated')
    end

    def destroy
      flash.notice = t('.destroyed') if @type.destroy
      redirect_to @event
    end

    private

    def find_event
      @event = events_scope.find(params[:event_id])
    end

    def find_type
      @type = authorize(@event.ticket_types.find(params[:id]))
    end

    def prepare_new
      @type = authorize(@event.ticket_types.new)
    end

    def date_params
      permitted_attributes @type
    end

    def events_scope
      Event.including_ticketing_disabled
    end
  end
end
