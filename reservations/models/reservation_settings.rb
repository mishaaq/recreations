class ReservationSettings
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :recreation_id, Integer
  property :for_time, Time
  property :slots, Integer
end
