Recreations::Base.controllers :user do

  put :update, :provides => :json do
    content_type :json

    current_user = User.first({:name => request.ip})
    if current_user.nil?
      halt 404
    end
    current_user.display_name = params[:display_name]
    current_user.email = params[:email]
    if current_user.save
      current_user.to_json
    else
      status 400
      current_user.errors.to_json
    end

  end

end
