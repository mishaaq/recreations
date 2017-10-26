Recreations::Reservations.controllers :reservation do
  layout 'application'

  resolv = Resolv.new

  before do # get user
    @current_user = User.first_or_new({:name => request.ip})
    unless @current_user.saved?
      begin
        display_name = resolv.getname(request.ip)
      rescue ResolvError => e
        display_name = @current_user.name
      end
      @current_user.display_name = display_name
      @current_user.save
      # TODO: add unhappy path
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
    @reservation = Reservation.create(params[:reservation].merge({:user_id => @current_user.id}))
    redirect url_for(:reservation, :index)
  end

  delete :destroy, :with => :id do
    # TODO: add authorization
    @reservation = Reservation.get(params[:id])
    @reservation.destroy
    redirect url_for(:reservation, :index)
  end

end
