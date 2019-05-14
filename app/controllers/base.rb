Recreations::Base.controllers :base do
  
  get :index, :map => '/' do
    redirect Recreations::Reservations.url_for(:reservations, :index)
  end

end
