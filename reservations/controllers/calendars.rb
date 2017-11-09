Recreations::Reservations.controllers :calendars do
  
  get :webcal, :with => :id do
    user = User.get(params[:id])
    if user.nil?
      halt 404
    end
    reservations = user.reservations.today
    calendar = Icalendar::Calendar.new
    calendar.x_wr_calname = 'Reservations'
    reservations.each do |r|
      time_interval = r.recreation.reservation_settings.for_time
      calendar.event do |e|
        e.dtstart  = r.time
        e.dtend    = r.time.advance({:hours => time_interval.hour, :minutes => time_interval.minute})
        e.summary  = "Reservation for #{r.recreation.name.downcase}."
        e.url      = absolute_url(:reservations, :index) + "##{reservation_anchor(r)}"
        e.alarm do |a|
          a.action  = 'DISPLAY'
          a.summary = "You have a reservation for #{r.recreation.name.downcase}."
          a.trigger = '-PT5M'
        end
      end
    end
    calendar.publish

    content_type 'text/calendar'
    calendar.to_ical
  end

end
