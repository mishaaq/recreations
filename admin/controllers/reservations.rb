Recreations::Admin.controllers :reservations do
  get :index do
    @title = "Reservations"
    @reservations = Reservation.all
    render 'reservations/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'reservation')
    @reservation = Reservation.new
    @users = User.all
    @recreations = Recreation.all
    render 'reservations/new'
  end

  post :create do
    @reservation = Reservation.new(params[:reservation])
    if @reservation.save
      @title = pat(:create_title, :model => "reservation #{@reservation.id}")
      flash[:success] = pat(:create_success, :model => 'Reservation')
      params[:save_and_continue] ? redirect(url(:reservations, :index)) : redirect(url(:reservations, :edit, :id => @reservation.id))
    else
      @title = pat(:create_title, :model => 'reservation')
      flash.now[:error] = pat(:create_error, :model => 'reservation')
      render 'reservations/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "reservation #{params[:id]}")
    @reservation = Reservation.get(params[:id])
    @users = User.all
    @recreations = Recreation.all
    if @reservation
      render 'reservations/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'reservation', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "reservation #{params[:id]}")
    @reservation = Reservation.get(params[:id])
    if @reservation
      if @reservation.update(params[:reservation])
        flash[:success] = pat(:update_success, :model => 'Reservation', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:reservations, :index)) :
          redirect(url(:reservations, :edit, :id => @reservation.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'reservation')
        render 'reservations/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'reservation', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Reservations"
    reservation = Reservation.get(params[:id])
    if reservation
      if reservation.destroy
        flash[:success] = pat(:delete_success, :model => 'Reservation', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'reservation')
      end
      redirect url(:reservations, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'reservation', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Reservations"
    unless params[:reservation_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'reservation')
      redirect(url(:reservations, :index))
    end
    ids = params[:reservation_ids].split(',').map(&:strip)
    reservations = Reservation.all(:id => ids)
    
    if reservations.destroy
    
      flash[:success] = pat(:destroy_many_success, :model => 'Reservations', :ids => "#{ids.join(', ')}")
    end
    redirect url(:reservations, :index)
  end
end
