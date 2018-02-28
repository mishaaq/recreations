Recreations::Base.controllers :user do

  put :update, :provides => :json do
    content_type :json

    current_user = Auth.by_cookie(cookies.signed)
    if current_user.nil?
      halt 404
    end
    current_user.display_name = params[:display_name] if params.include?('email')
    current_user.email = params[:email] if params.include?('email')
    current_user.spark_integration = params[:spark_integration] if params.include?('spark_integration')
    if current_user.save
      current_user.to_json
    else
      status 400
      current_user.errors.to_json
    end

  end

end
