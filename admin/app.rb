require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'

module Recreations
  class Admin < Padrino::Application
    use IdentityMap
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Admin::AccessControl

    ##
    # Application configuration options
    #
    # set :raise_errors, true         # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true          # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true      # Shows a stack trace in browser (default for development)
    # set :logging, true              # Logging in STDOUT for development and file for production (default only for development)
    set :public_folder, Padrino.root("public/admin")   # Location for static assets (default root/public)
    # set :reload, false              # Reload application files (default in development)
    # set :default_builder, "foo"     # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"         # Set path for I18n translations (default your_app/locales)
    # disable :sessions               # Disabled sessions by default (enable if needed)
    # disable :flash                  # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout              # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    set :admin_model, 'Account'
    set :login_page,  '/sessions/new'

    enable  :sessions
    disable :store_location

    access_control.roles_for :any do |role|
      role.protect '/'
      role.allow   '/sessions'
    end

    access_control.roles_for :admin do |role|
      role.project_module :settings, '/settings'
      role.project_module :accounts, '/accounts'
      role.project_module :recreations, '/recreations'
      role.project_module :reservations, '/reservations'
      role.project_module :users, '/users'
    end

    # Custom error management 
    error(403) { @title = "Error 403"; render('errors/403', :layout => :error) }
    error(404) { @title = "Error 404"; render('errors/404', :layout => :error) }
    error(500) { @title = "Error 500"; render('errors/500', :layout => :error) }

    before do
      Time.zone = `if [ -f /etc/timezone ]; then
        cat /etc/timezone
      elif [ -h /etc/localtime ]; then
        echo $(basename $(dirname \`readlink /etc/localtime\`))/$(basename \`readlink /etc/localtime\`)
      fi`.chomp
    end

  end
end
