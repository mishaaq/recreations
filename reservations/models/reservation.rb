class Reservation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :time, DateTime
  property :user_id, Integer
  property :recreation_id, Integer

  belongs_to :user
  belongs_to :recreation

  validates_presence_of :time
  validates_presence_of :user_id
  validates_presence_of :recreation_id

  def time=(new_time)
    if new_time.kind_of?(String)
      new_time = Time.zone.parse(new_time).to_datetime
    end
    new_time.change(:offset => Time.zone.now.to_datetime.offset) if new_time.utc_offset != Time.zone.utc_offset
    attribute_set(:time, new_time)
  end

  def self.today(query={})
    now = Time.now
  	today_begin = Time.new(now.year, now.month, now.day, 0, 0, 0)
  	today_end = Time.new(now.year, now.month, now.day, 23, 59, 0)
  	all({:time.gte => today_begin, :time.lte => today_end}.merge(query))
  end

end
