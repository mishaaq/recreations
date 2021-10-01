require 'icalendar'
require 'uuidtools'

Recreations::Reservations.controllers :reservations do
  layout 'application'

  before do # get user by cookie
    @current_user = Auth.by_token(cookie.signed)
  end

  before :index do # migrate user to cookie authentication
    unless @current_user.present?
      @current_user = Auth.by_cookie(cookie.signed) || Auth.by_ip(request.ip)
      cookie.signed['login'] = @current_user.name
      redirect Recreations::Base.url_for(:user, :token)
    end
  end

  after do
    cookie.permanent.signed['token'] = @current_user.auth_token unless @current_user.auth_token.blank?
  end
  
  get :index, :map => '/' do
    @date = params[:date].present? ? Time.strptime(params[:date], "%Y-%m-%d") : Time.now

    @reservations = {}
    @recreations = Recreation.all
    @recreations.each do |recreation|
      @reservations[recreation.name] = []
      current_reservations = Reservation.at(@date, {:recreation => recreation, :order => [:time.asc]})
      start_time = Time.new(@date.year, @date.month, @date.day,
                            recreation.reservation_settings.available_from.hour,
                            recreation.reservation_settings.available_from.minute)
      end_time = Time.new(@date.year, @date.month, @date.day,
                          recreation.reservation_settings.available_to.hour,
                          recreation.reservation_settings.available_to.minute)
      time_table = create_time_table(recreation.reservation_settings.for_time,
                                     start_time, end_time)
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
    redirect url_for(:reservations, :index, {:date => reservation.time.strftime("%F"), :anchor => reservation_anchor(reservation)})
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
    redirect url_for(:reservations, :index, {:date => reservation.time.strftime("%F"), :anchor => reservation_anchor(reservation)})
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
    redirect url_for(:reservations, :index, {:date => reservation.time.strftime("%F"), :anchor => reservation_anchor(reservation)})
  end

end
