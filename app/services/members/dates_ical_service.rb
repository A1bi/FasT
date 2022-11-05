# frozen_string_literal: true

require 'icalendar/tzinfo'

module Members
  class DatesIcalService
    def ics
      dates.find_each do |date|
        calendar.event do |e|
          e.uid             = "FASTEVENT-#{date.id}"
          e.dtstart         = cal_date(date.datetime)
          e.dtend           = cal_date(90.minutes.after(date.datetime))
          e.summary         = date.title
          e.description     = date.info
          e.location        = date.location
          e.ip_class        = 'PUBLIC'
          e.last_modified   = date.updated_at

          e.alarm do |a|
            a.action        = 'AUDIO'
            a.trigger       = '-P0DT0H45M0S'
          end
        end
      end

      calendar.to_ical
    end

    def dates
      @dates ||= Date.where('datetime > ?', 2.years.ago)
    end

    private

    def calendar
      @calendar ||= begin
        cal = Icalendar::Calendar.new
        cal.x_wr_calname = translation(:calname)
        cal.x_wr_caldesc = translation(:caldesc)
        cal.x_published_ttl = 'PT1D'
        cal.add_timezone(timezone)
        cal.publish
        cal
      end
    end

    def cal_date(date)
      Icalendar::Values::DateTime.new(date, tzid:)
    end

    def timezone
      zone = TZInfo::Timezone.get(tzid)
      zone.ical_timezone(dates.first.datetime)
    end

    def tzid
      Rails.application.config.time_zone
    end

    def translation(key)
      I18n.t(key, scope: %i[members dates ics])
    end
  end
end
