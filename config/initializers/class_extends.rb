module ClassExtends
  require 'date'
  class Time
    def to_datetime
      # Convert seconds + microseconds into a fractional number of seconds
      seconds = sec + Rational(usec, 10**6)

      # Convert a UTC offset measured in minutes to one measured in a
      # fraction of a day.
      offset = Rational(utc_offset, 60 * 60 * 24)
      DateTime.new(year, month, day, hour, min, seconds, offset)
    end
  end

  require 'rack'
  class Rack::Request
    X_MOBILE_DEVICE = 'X_MOBILE_DEVICE'.freeze

    def mobile_browser?; get_header(X_MOBILE_DEVICE) end
  end
end