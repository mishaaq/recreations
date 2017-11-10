Recreations::Reservations.controllers :calendars do
  
  get :webcal, :with => :id do
    user = User.get(params[:id])
    if user.nil?
      halt 404
    end

    calendar = Recreations::ReservationsCalendar.new
    user.reservations.each {|r| calendar << r }

    content_type 'text/calendar'
    calendar.to_ical
  end

  get :ical, :with => :id do
    reservation = Reservation.get(params[:id])
    if reservation.nil?
      halt 404
    end

    calendar = Recreations::ReservationsCalendar.new
    calendar << reservation

    content_type 'text/calendar'
    calendar.to_ical
  end
end
