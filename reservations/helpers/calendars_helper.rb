# Helper methods defined here can be accessed in any controller or view in the application

require 'uri'
require 'icalendar/tzinfo'

module Recreations
  class Reservations
    module CalendarsHelper

      def webcal_url(*args)
        url = absolute_url(*args)
        uri = URI(url)
        uri.scheme = 'webcal'
        uri.to_s
      end

    end

    helpers CalendarsHelper
  end

  class ReservationsCalendar

    def initialize
      @calendar = Icalendar::Calendar.new
      @calendar.x_wr_calname = 'Reservations'
      @calendar.x_published_ttl = 'PT5M'
      tzid = Time.zone.name
      timezone = TZInfo::Timezone.get(tzid)
      @calendar.add_timezone(timezone.ical_timezone(Time.now))
    end

    def <<(r)
      time_interval = r.recreation.reservation_settings.for_time
      @calendar.event do |e|
        e.dtstart     = Icalendar::Values::DateTime.new(r.time, :tzid => Time.zone.name)
        e.dtend       = Icalendar::Values::DateTime.new(r.time.advance({:hours => time_interval.hour,
                                                                              :minutes => time_interval.minute}), :tzid => Time.zone.name)
        e.summary     = r.recreation.name
        e.description = "You have reservation for #{r.recreation.name.downcase}."
        #e.url         = absolute_url(:reservations, :index) + "##{reservation_anchor(r)}"
        e.alarm do |a|
          a.action      = 'DISPLAY'
          a.summary     = "Reservation for #{r.recreation.name.downcase}."
          a.description = "You have reserved #{r.recreation.name.downcase}."
          a.trigger     = '-PT5M'
        end
      end
    end

    def to_ical
      @calendar.publish
      @calendar.to_ical
    end
  end
end
