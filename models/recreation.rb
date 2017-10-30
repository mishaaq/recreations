class Recreation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String

  has n, :reservations, :constraint => :destroy
  has 1, :reservation_settings, :constraint => :destroy

  accepts_nested_attributes_for :reservation_settings, :allow_destroy => true
end
