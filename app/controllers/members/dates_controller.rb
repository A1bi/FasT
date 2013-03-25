module Members
	class DatesController < BaseController
		before_filter :find_date, :only => [:edit, :update, :destroy]
	
		restrict_access_to_group :admin
		ignore_restrictions :only => [:index]
	
		caches_page :index
	
		def index
			respond_to do |format|
		    format.ics {
					require 'icalendar'
		
					cal = Icalendar::Calendar.new
					scope = [:members, :dates, :ics]
					cal.custom_property "X-WR-CALNAME", t(:calname, :scope => scope)
					cal.custom_property "X-WR-CALDESC", t(:caldesc, :scope => scope)
					cal.custom_property "X-PUBLISHED-TTL", "PT1D"
					cal.publish
					cal.timezone do
			      timezone_id             "Europe/Berlin"
			    end
				
					Date.not_expired.find_each do |date|
						cal.event do
							uid							"FASTEVENT-#{date.id}"
							dtstart					date.datetime.to_datetime
							dtend						(date.datetime + 90.minutes).to_datetime
							summary					I18n.t(:summary, :scope => scope)
							description			date.info
							location				date.location
							klass						"PUBLIC"
							last_modified		date.updated_at.to_datetime
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
	    @date = Date.new(params[:members_date])

			if @date.save
				expire_cache
				redirect_to members_root_path
			else
				render action: :new
			end
	  end

	  def update
	  	if @date.update_attributes(params[:members_date])
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
			expire_page :action => :index, :format => :ics
		end
	end
end
