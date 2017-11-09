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
      time_table = create_time_table(recreation.reservation_settings.for_time)
      @reservations[recreation.name] = time_table.map do |time|
        new_reservation = nil
        if !current_reservations.empty? && current_reservations.first.time == time
          new_reservation = current_reservations.shift
        else
          new_reservation = Reservation.new({:recreation => recreation, :time => time})
        end

        new_reservation
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
      flash.success = 'Reservation canceled.'
    end
    redirect url_for(:reservations, :index) + "##{reservation_anchor(reservation)}"
  end

end
