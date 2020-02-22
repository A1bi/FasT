# frozen_string_literal: true

module Members
  class DatesController < ApplicationController
    before_action :find_date, only: %i[edit update destroy]

    def index
      authorize dates_ical_service.dates
      return unless stale? dates_ical_service.dates

      respond_to do |format|
        format.ics { render body: dates_ical_service.ics }
      end
    end

    def new
      @date = authorize Date.new
    end

    def edit; end

    def create
      @date = authorize Date.new(date_params)

      if @date.save
        redirect_to members_root_path
      else
        render action: :new
      end
    end

    def update
      if @date.update(date_params)
        redirect_to members_root_path, notice: t('application.saved_changes')
      else
        render action: :edit
      end
    end

    def destroy
      @date.destroy

      redirect_to members_root_path
    end

    private

    def find_date
      @date = authorize Date.find(params[:id])
    end

    def dates_ical_service
      @dates_ical_service ||= DatesIcalService.new
    end

    def date_params
      params.require(:members_date).permit(:datetime, :info, :location, :title)
    end
  end
end
