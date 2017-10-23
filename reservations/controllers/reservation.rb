Recreations::Reservations.controllers :reservation do
  layout 'application'
  
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  
  get :index, :map => '/' do
    @recreations = Recreation.all
    @reservations = {}
    @reservations = @recreations.each { |recreation| @reservations[recreation.name] = Reservations.all(:recreation => recreation) }
    render 'index'
  end

  post :create do
    @reservation = Reservation.new(params[:reservation])
    EntityManager.save(@reservation)
    redirect('/')
  end

end
