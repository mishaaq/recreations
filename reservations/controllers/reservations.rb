require 'icalendar'

Recreations::Reservations.controllers :reservations do
  layout 'application'

  resolv = Resolv.new

  before do # get user
    @current_user = User.first_or_new({:name => request.ip})
    unless @current_user.saved?
      begin
        display_name = resolv.getname(request.ip).split('.').first
      rescue Resolv::ResolvError => e
        display_name = @current_user.name
      end
      @current_user.display_name = display_name
      unless @current_user.save
        halt 500
      end
    end
  end
  
  get :index, :map => '/' do
    @reservations = {}
    @recreations = Recreation.all
    @recreations.each do |recreation|
      @reservations[recreation.name] = []
      current_reservations = Reservation.today({:recreation => recreation, :order => [:time.asc]})
      time_table = create_time_table(recreation.reservation_settings.for_time,
                                     recreation.reservation_settings.available_from,
                                     recreation.reservation_settings.available_to)
      @reservations[recreation.name] = time_table.map do |time|
        if !current_reservations.empty? && current_reservations.first.time == time
          current_reservations.shift
        else
          Reservation.new({:recreation => recreation, :time => time})
        end
      end

      @reservations
    end

    render 'index'
  end

  post :create do
    reservation = Reservation.first_or_new(params[:reservation])
    if validate_create(reservation)
      reservation.user = @current_user
      reservation.save
      schedule_notification(reservation)
      flash.success = 'Reservation made.'
    end
    redirect url_for(:reservations, :index) + "##{reservation_anchor(reservation)}"
  end

  delete :destroy, :with => :id do
    reservation = Reservation.get(params[:id])
    if reservation.nil?
      halt 404
    end

    if validate_delete(reservation)
      reservation.destroy
      unschedule_notification(reservation)
      flash.success = 'Reservation canceled.'
    end
    redirect url_for(:reservations, :index) + "##{reservation_anchor(reservation)}"
  end

end
