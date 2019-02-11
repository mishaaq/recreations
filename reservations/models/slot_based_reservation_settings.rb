class SlotBasedReservationSettings < ReservationSettings

  # property <name>, <type>
  property :max_guests, Integer
  property :monday, CommaSeparatedList
  property :tuesday, CommaSeparatedList
  property :wednesday, CommaSeparatedList
  property :thursday, CommaSeparatedList
  property :friday, CommaSeparatedList
  property :saturday, CommaSeparatedList
  property :sunday, CommaSeparatedList

  validates_presence_of :max_guests
  validates_numericality_of :max_guests
end
