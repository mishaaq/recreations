class ReservationSettings
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :recreation_id, Integer
  property :type, Discriminator

  belongs_to :recreation

  # validates_presence_of :recreation_id
end
