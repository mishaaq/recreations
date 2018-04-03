class Participation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :reservation_id, Integer

  belongs_to :user, User, :key => true
  belongs_to :reservation, Reservation, :key => true
end
