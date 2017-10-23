class Reservation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :time, DateTime
  property :user_id, Integer
  property :recreation_id, Integer

  belongs_to :user
  belongs_to :recreation
end
