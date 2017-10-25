class ReservationSettings
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :recreation_id, Integer
  property :for_time, DateTime
  property :slots, Integer

  belongs_to :recreation

  # validates_presence_of :for_time, :slots
  # validates_format_of :for_time, :with => /^\d?\d:\d\d$/
  # validates_numericality_of :slots
end
