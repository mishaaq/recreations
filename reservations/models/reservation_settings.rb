class ReservationSettings
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :recreation_id, Integer
  property :for_time, DateTime
  property :slots, Integer
  property :available_from, DateTime, :default => DateTime.new(1970, 1, 1, 8, 0, 0)
  property :available_to, DateTime, :default => DateTime.new(1970, 1, 1, 17, 0, 0)
  property :weekdays, Flag[ :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday ], :default => [ :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday ]

  belongs_to :recreation

  # validates_presence_of :recreation_id
  validates_presence_of :for_time
  validates_presence_of :available_from
  validates_presence_of :available_to
  validates_presence_of :slots
  validates_numericality_of :slots

  before :save do |reservation_settings|
    [reservation_settings.for_time, reservation_settings.available_from, reservation_settings.available_to].each do |time|
      time.change({
          :year => 1970,
          :month => 1,
          :day => 1
    })
    end

  end
end
