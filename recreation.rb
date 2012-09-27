require 'time'


class Recreation
  def initialize(label, time_interval, reservation_time, reservations_per_user=1)
    exclude_end = time_interval.respond_to?(:exclude_end?) ? time_interval.exclude_end? : true
    time_interval = [time_interval.first, time_interval.last].map { |h| h.to_s + ":00" } if time_interval.first.integer? # convert to time strings
    range_of_time = Range.new(Time.parse(time_interval.first), Time.parse(time_interval.last), exclude_end) # create time range
    reservation_time = Time.parse(reservation_time.to_s) # support reservation_time as String ("h:mm") or Time
    seconds = reservation_time.hour * 3600 + reservation_time.min * 60 + reservation_time.sec

    @opening_hours = range_of_time.step(seconds).to_a
    @label = label
    @reservations_per_user = reservations_per_user
    @reservation_time = Time.at(seconds)
    @reservations = {}
  end

  def reserve(name, hour)
    hr = Time.parse(hour.to_s)
    raise ReservationException.new($localize[:"reserve-in-past"]) if hr + @reservation_time.to_i < Time.now
    made = @reservations.values.select { |reservation| reservation == name }
    raise ReservationException.new($localize[:"max-reservations"]) unless made.length < @reservations_per_user
    raise ReservationException.new($localize[:"reservation-occupied"]) unless @reservations[hr].nil?
    @reservations[hr] = name
  end

  def cancel(name, hour)
    hr = Time.parse(hour.to_s)
    raise ReservationException.new($localize[:"cancel-in-past"]) if hr < Time.now
    raise ReservationException.new($localize[:"cannot-cancel"]) unless name == @reservations[hr]
    @reservations[hr] = nil
  end

  def label
    @label
  end

  def reservations
    Marshal::load(Marshal.dump(@reservations)).freeze
  end

  def clear
    @reservations = {}
  end
  
  def dump
    Marshal.dump(@reservations)
  end
  
  def load(dump)
    @reservations = Marshal.load(dump) unless dump.nil?
  end
    
  def opening_hours
    @opening_hours
  end

  def reservation_time
    @reservation_time
  end

  class ReservationException < Exception
  end
end
