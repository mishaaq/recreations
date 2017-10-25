Recreations::Admin.controllers :recreations do
  get :index do
    @title = "Recreations"
    @recreations = Recreation.all
    render 'recreations/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'recreation')
    @recreation = Recreation.new
    @reservation_settings.new
    render 'recreations/new'
  end

  post :create do
    @recreation = Recreation.new(params[:recreation])
    @recreation.reservation_settings = ReservationSettings.new(params[:reservation_settings])
    Recreation.transaction do |t|
      begin
        if @recreation.save && @recreation.reservation_settings.save
          @title = pat(:create_title, :model => "recreation #{@recreation.id}")
          flash[:success] = pat(:create_success, :model => 'Recreation')
          params[:save_and_continue] ? redirect(url(:recreations, :index)) : redirect(url(:recreations, :edit, :id => @recreation.id))
        else
          @title = pat(:create_title, :model => 'recreation')
          flash.now[:error] = pat(:create_error, :model => 'recreation')
          render 'recreations/new'
        end
      rescue DataObjects::Error
        t.rollback
      end
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "recreation #{params[:id]}")
    @recreation = Recreation.get(params[:id])
    @reservation_settings = ReservationSettings.get(:recreation_id => @recreation.id)
    if @recreation
      render 'recreations/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'recreation', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "recreation #{params[:id]}")
    @recreation = Recreation.get(params[:id])
    if @recreation
      Recreation.transaction do |t|
        begin
          if @recreation.update(params[:recreation]) && @recreation.reservation_settings.update(params[:reservation_settings].merge({:recreation_id => params[:id]}))
            flash[:success] = pat(:update_success, :model => 'Recreation', :id =>  "#{params[:id]}")
            params[:save_and_continue] ?
              redirect(url(:recreations, :index)) :
              redirect(url(:recreations, :edit, :id => @recreation.id))
          else
            flash.now[:error] = pat(:update_error, :model => 'recreation')
            render 'recreations/edit'
          end
        rescue DataObjects::Error
          t.rollback
        end
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'recreation', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Recreations"
    recreation = Recreation.get(params[:id])
    if recreation
      if recreation.destroy
        flash[:success] = pat(:delete_success, :model => 'Recreation', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'recreation')
      end
      redirect url(:recreations, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'recreation', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Recreations"
    unless params[:recreation_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'recreation')
      redirect(url(:recreations, :index))
    end
    ids = params[:recreation_ids].split(',').map(&:strip)
    recreations = Recreation.all(:id => ids)
    
    if recreations.destroy
    
      flash[:success] = pat(:destroy_many_success, :model => 'Recreations', :ids => "#{ids.join(', ')}")
    end
    redirect url(:recreations, :index)
  end
end
