class User
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :display_name, String, :required => true

  has n, :reservations, :constraint => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :display_name
end
