class Recreation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String

  has n, :reservations
  has 1, :reservation_settings

  accepts_nested_attributes_for :reservation_settings, :allow_destroy => true
end
