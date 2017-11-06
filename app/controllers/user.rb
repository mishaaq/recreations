Recreations::Base.controllers :user do
  
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

  put :update do
    current_user = User.first({:name => request.ip})
    if current_user.nil?
      halt 404
    end
    current_user.display_name = params[:value]
    current_user.save!
  end

end
