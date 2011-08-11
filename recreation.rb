require 'time'


class Recreation
  def initialize(label, opening_hours, reservations_per_user=1)
    @label = label
    @opening_hours = opening_hours.clone.freeze
    @reservations_per_user = reservations_per_user || 1
    @reservations = {}
  end

  def reserve(name, hour)
    hr = Time.parse(hour.to_s)
    raise ReservationException.new($localize[:"reserve-in-past"]) if hr < Time.now
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
  
  def opening_hours
    @opening_hours
  end
  
  class ReservationException < Exception
  end
end

class RecreationFactory
  def self.create(label, hours, interval, max_per_user=nil)
    hrs = hours.dup
    exclude_end = hours.respond_to?(:exclude_end?) || true
    hrs = [hrs.first, hrs.last].map {|h| h.to_s + ":00" } if hrs.first.integer? # support (int..int) or [int, int]
    hours_time = Range.new(Time.parse(hrs.first.to_s), Time.parse(hrs.last.to_s), exclude_end)
    interval_time = Time.parse(interval.to_s) # support interval as String ("h:mm") or Time
    seconds = interval_time.hour * 3600 + interval_time.min * 60 + interval_time.sec
    opening_hours = hours_time.step(seconds).to_a
    Recreation.new(label, opening_hours, max_per_user)
  end
end
