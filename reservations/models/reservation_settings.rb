class ReservationSettings
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :recreation_id, Integer
  property :for_time, DateTime
  property :slots, Integer

  belongs_to :recreation

  validates_presence_of :for_time, :slots
  validates_numericality_of :slots

  before :save do |reservation_settings|
    time = reservation_settings.for_time
    reservation_settings.for_time = DateTime.new(1970, 1, 1, time.hour, time.min, time.sec)
  end
end
