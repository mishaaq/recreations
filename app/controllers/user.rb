require 'net/ldap'

Recreations::Base.controllers :user do

  before :update do
    @current_user = Auth.by_token(cookies.signed)
    halt 403 unless @current_user
  end

  put :update, :provides => :json do
    content_type :json

    @current_user.display_name = params[:display_name] if params.include?('email')
    @current_user.email = params[:email] if params.include?('email')
    @current_user.spark_integration = params[:spark_integration] if params.include?('spark_integration')
    if @current_user.save
      @current_user.to_json
    else
      status 400
      @current_user.errors.to_json
    end

  end

  before :token do
    @current_user = Auth.by_cookie(cookie.signed)
    return halt 401 unless @current_user
  end

  ldap_config = HashWithIndifferentAccess.new(YAML.load_file(Padrino.root('config/config.yml'))['ldap'])
  ldap = Net::LDAP.new(ldap_config)

  get :token, :map => '/token' do
    @domain = ldap_config[:domain]
    render :login
  end

  post :token, :map => '/token' do
    if @params['username'].blank? || @params['password'].blank?
      flash.error = "Username or password blank"
      redirect url_for(:user, :token)
    end
    @params[:username].downcase!

    ldap.authenticate(@params['username'] + ldap_config[:domain], @params['password'])
    begin
      if ldap.bind
        new_token = Auth.generate_token(@params['username'])
        duplicate = User.first({:auth_token => new_token})
        if duplicate
          duplicate.merge(@current_user)
          @current_user.destroy
          @current_user = duplicate
        end
        @current_user.attributes = {
            :auth_token => new_token,
            :name => @params[:username]
        }
        if @current_user.save
          cookie.permanent.signed['token'] = @current_user.auth_token
          cookie.delete('login')
          redirect url_for(:base, :index)
        else
          flash.error = @current_user.errors
          redirect url_for(:user, :token, :id => @params[:id])
        end
      else
        flash.error = "Invalid credentials"
        redirect url_for(:user, :token, :id => @params[:id])
      end
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Net::LDAP::ConnectionRefusedError
      halt 503
    end
  end

end
