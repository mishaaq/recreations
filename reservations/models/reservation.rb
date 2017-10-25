class Reservation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :time, DateTime
  property :user_id, Integer
  property :recreation_id, Integer

  belongs_to :user
  belongs_to :recreation


  def self.today(query={})
    now = Time.now
  	today_at_8 = Time.new(now.year, now.month, now.day, 8, 0, 0)
  	today_at_17 = Time.new(now.year, now.month, now.day, 17, 0, 0)
  	all({:time.gt => today_at_8, :time.lt => today_at_17}.merge(query))
  end

end
