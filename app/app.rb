require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/date_time/conversions'
require 'active_support/core_ext/time/zones'

module Recreations
  class Base < Padrino::Application
    register Padrino::Helpers

    ##
    # Application configuration options
    #
    # set :raise_errors, true         # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true          # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true      # Shows a stack trace in browser (default for development)
    # set :logging, true              # Logging in STDOUT for development and file for production (default only for development)
    set :public_folder, Padrino.root("public")   # Location for static assets (default root/public)
    # set :reload, false              # Reload application files (default in development)
    # set :default_builder, "foo"     # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"         # Set path for I18n translations (default your_app/locales)
    # disable :sessions               # Disabled sessions by default (enable if needed)
    # disable :flash                  # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout              # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    enable  :sessions

    before do
      Time.zone = `if [ -f /etc/timezone ]; then
        cat /etc/timezone
      elif [ -h /etc/localtime ]; then
        readlink /etc/localtime | sed "s/\\/usr\\/share\\/zoneinfo\\///"
      fi`.chomp
    end

  end
end
