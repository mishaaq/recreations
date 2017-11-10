Recreations::Reservations.controllers :calendars do
  
  get :user, :with => :id, :provides => :ics do
    user = User.get(params[:id])
    if user.nil?
      halt 404
    end

    calendar = Recreations::ReservationsCalendar.new
    user.reservations.each {|r| calendar << r }

    content_type 'text/calendar'
    attachment "#{user.display_name}.ics"
    expires 60*5, :no_cache, :no_store, :must_revalidate

    calendar.to_ical
  end
end
