class User
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :display_name, String

  has n, :reservations, :constraint => :destroy
end
