Recreations::Reservations.controllers :calendars do
  
  get :user, :with => :id, :provides => :ics do
    user = User.get(params[:id])
    if user.nil?
      halt 404
    end

    calendar = Recreations::ReservationsCalendar.new('Reservations')
    user.reservations.each {|r| calendar << r }

    content_type 'text/calendar'
    attachment "#{user.display_name}.ics"
    expires 60*5, :no_cache, :no_store, :must_revalidate

    calendar.to_ical
  end

  get :reservation, :with => :id, :provides => :ics do
    reservation = Reservation.get(params[:id])
    if reservation.nil?
      halt 404
    end

    calendar = Recreations::ReservationsCalendar.new
    calendar << reservation

    content_type 'text/calendar'
    attachment "reservation-#{reservation.id}.ics"
    expires 60*5, :no_cache, :no_store, :must_revalidate

    calendar.to_ical
  end
end
