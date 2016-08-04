module Members
  class DatesController < BaseController
    before_filter :find_date, only: [:edit, :update, :destroy]

    restrict_access_to_group :admin
    ignore_restrictions only: [:index]

    caches_page :index

    def index
      respond_to do |format|
        format.ics {
          require 'icalendar'

          cal = Icalendar::Calendar.new
          scope = [:members, :dates, :ics]
          cal.x_wr_calname = t(:calname, scope: scope)
          cal.x_wr_caldesc = t(:caldesc, scope: scope)
          cal.x_published_ttl = "PT1D"
          cal.publish
          cal.timezone do |t|
            t.tzid = "Europe/Berlin"
          end

          Members::Date.find_each do |date|
            cal.event do |e|
              e.uid             =	"FASTEVENT-#{date.id}"
              e.dtstart				  = date.datetime.to_datetime
              e.dtend						= (date.datetime + 90.minutes).to_datetime
              e.summary					= date.title
              e.description			= date.info
              e.location				= date.location
              e.ip_class				= "PUBLIC"
              e.last_modified		= date.updated_at.to_datetime

              e.alarm do |a|
                a.action        = "AUDIO"
                a.trigger       = "-P0DT0H45M0S"
              end
            end
          end

          render text: cal.to_ical
        }
      end
    end

    def new
      @date = Date.new
    end

    def edit
    end

    def create
      @date = Date.new(date_params)

      if @date.save
        expire_cache
        redirect_to members_root_path
      else
        render action: :new
      end
    end

    def update
      if @date.update_attributes(date_params)
        expire_cache
        redirect_to members_root_path, notice: t("application.saved_changes")
      else
        render action: :edit
      end
    end

    def destroy
      @date.destroy
      expire_cache

      redirect_to members_root_path
    end

    private

    def find_date
      @date = Date.find(params[:id])
    end

    def expire_cache
      expire_page action: :index, format: :ics
    end

    def date_params
      params.require(:members_date).permit(:datetime, :info, :location, :title)
    end
  end
end
