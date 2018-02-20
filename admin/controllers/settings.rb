Recreations::Admin.controllers :settings do
  get :index do
    @title = "Settings"
    @settings = Settings.first
    render 'settings/edit'
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "settings #{params[:id]}")
    @settings = Settings.get(params[:id])
    if @settings
      if @settings.update(params[:settings])
        flash[:success] = pat(:update_success, :model => 'Settings', :id =>  "#{params[:id]}")
        redirect(url(:settings, :index))
      else
        flash.now[:error] = pat(:update_error, :model => 'settings')
        render 'settings/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'settings', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Settings"
    settings = Settings.get(params[:id])
    if settings
      if settings.destroy
        flash[:success] = pat(:delete_success, :model => 'Settings', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'settings')
      end
      redirect url(:settings, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'settings', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Settings"
    unless params[:settings_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'settings')
      redirect(url(:settings, :index))
    end
    ids = params[:settings_ids].split(',').map(&:strip)
    settings = Settings.all(:id => ids)
    
    if settings.destroy
    
      flash[:success] = pat(:destroy_many_success, :model => 'Settings', :ids => "#{ids.join(', ')}")
    end
    redirect url(:settings, :index)
  end
end
