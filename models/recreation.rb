class Recreation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String

  has n, :reservations, :constraint => :destroy
  has 1, :reservation_settings, :constraint => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  accepts_nested_attributes_for :reservation_settings, :allow_destroy => true
end
