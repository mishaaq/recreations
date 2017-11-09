# Helper methods defined here can be accessed in any controller or view in the application

require 'uri'

module Recreations
  class Reservations
    module CalendarsHelper

      def webcal_url(*args)
        url = absolute_url(*args)
        uri = URI(url)
        uri.scheme = 'webcal'
        uri.to_s
      end

    end

    helpers CalendarsHelper
  end
end
