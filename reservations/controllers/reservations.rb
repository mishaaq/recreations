require 'icalendar'
require 'uuidtools'

Recreations::Reservations.controllers :reservations do
  layout 'application'

  before do # get user by cookie
    @current_user = Auth.by_cookie(cookies.signed)
  end

  before :index do # migrate user to cookie authentication
    unless @current_user.present?
      @current_user = Auth.by_ip(request.ip)
      @current_user.name = UUIDTools::UUID.random_create.to_s
      unless @current_user.save
        halt 500
      end
    end
  end

  after do
    cookie.permanent.signed['login'] = @current_user.name if @current_user.present?
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
    halt 401 if @current_user.blank?
    reservation = Reservation.first_or_new(params[:reservation])
    if validate_create(reservation)
      reservation.user = @current_user
      reservation.save
      schedule_notification(reservation)
      flash.success = 'Reservation made.'
    end
    redirect url_for(:reservations, :index) + "##{reservation_anchor(reservation)}"
  end

  put :update, :with => :id do
    reservation = Reservation.get(params[:id])
    if reservation.nil?
      halt 404
    end

    # add self as a participant
    if reservation.user != @current_user
      reservation.participants << @current_user
      reservation.save
      flash.success = 'Participation added.'
    end
    redirect url_for(:reservations, :index) + "##{reservation_anchor(reservation)}"
  end

  delete :destroy, :with => :id do
    reservation = Reservation.get(params[:id])
    if reservation.nil?
      halt 404
    end

    if reservation.user == @current_user
      if validate_delete(reservation)
        reservation.destroy
        unschedule_notification(reservation)
        flash.success = 'Reservation canceled.'
      end
    else
      reservation.participations.all(:user => @current_user).destroy
      reservation.save
      flash.success = 'Participation removed.'
    end
    redirect url_for(:reservations, :index) + "##{reservation_anchor(reservation)}"
  end

end
