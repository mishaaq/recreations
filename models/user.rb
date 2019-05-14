require 'dm-serializer'

class User
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :display_name, String, :required => true
  property :email, String
  property :spark_integration, Boolean
  property :auth_token, String, :default => ''

  has n, :reservations, :constraint => :destroy
  has n, :participations, :child_key => [ :user_id ], :constraint => :destroy
  has n, :presences, Reservation, :through => :participations, :via => :reservation

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :display_name
  validates_format_of :email, :as => :email_address

  # moves all associations from other_user to self
  def merge(other_user)
    return unless other_user.instance_of? User

    reservations_to_move = other_user.reservations
    reservations_to_move.update({:user_id => id})
    reservations.concat(reservations_to_move).save
    reservations.reload
    reservations_to_move.reload

    participations_to_move = other_user.participations
    participations_to_move.update({:user_id => id})
    participations.concat(participations_to_move).save
    participations.reload
    participations_to_move.reload
  end
end
