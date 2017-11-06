Recreations::Base.controllers :base do
  
  get :index, :map => '/' do
    redirect '/reserve'
  end

end
