class User
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String

  has n, :reservations
end
