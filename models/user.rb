require 'dm-serializer'

class User
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :display_name, String, :required => true
  property :email, String
  property :spark_integration, Boolean

  has n, :reservations, :constraint => :destroy
  has n, :participations, :child_key => [ :user_id ], :constraint => :destroy
  has n, :presences, Reservation, :through => :participations, :via => :reservation

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :display_name
  validates_format_of :email, :as => :email_address
end
