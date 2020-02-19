module Members
  class DatesController < ApplicationController
    before_action :find_date, only: %i[edit update destroy]

    def index
      @dates = authorize Members::Date.all
      respond_to do |format|
        format.ics do
          render plain: (Rails.cache.fetch([:members, :dates, :ics, @dates]) do
            cal = Icalendar::Calendar.new
            scope = %i[members dates ics]
            cal.x_wr_calname = t(:calname, scope: scope)
            cal.x_wr_caldesc = t(:caldesc, scope: scope)
            cal.x_published_ttl = 'PT1D'
            cal.publish
            cal.timezone do |t|
              t.tzid = 'Europe/Berlin'
            end

            @dates.each do |date|
              cal.event do |e|
                e.uid             = "FASTEVENT-#{date.id}"
                e.dtstart         = date.datetime.to_datetime
                e.dtend           = (date.datetime + 90.minutes).to_datetime
                e.summary         = date.title
                e.description     = date.info
                e.location        = date.location
                e.ip_class        = 'PUBLIC'
                e.last_modified   = date.updated_at.to_datetime

                e.alarm do |a|
                  a.action        = 'AUDIO'
                  a.trigger       = '-P0DT0H45M0S'
                end
              end
            end

            cal.to_ical
          end)
        end
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
      if @date.update_attributes(date_params)
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

    def date_params
      params.require(:members_date).permit(:datetime, :info, :location, :title)
    end
  end
end
