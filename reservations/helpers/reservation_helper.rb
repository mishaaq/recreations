# Helper methods defined here can be accessed in any controller or view in the application

module Recreations
  class Reservations
    module ReservationHelper
      
      def create_time_table(time_interval)
				interval = Time.gm(1970, 1, 1, time_interval.hour, time_interval.min, time_interval.sec)
      	now = Time.now
      	start_time = Time.new(now.year, now.month, now.day, 8, 0, 0)
      	end_time = Time.new(now.year, now.month, now.day, 17, 0, 0)
      	time_table = []
      	current = start_time
      	begin
      		time_table.push(current.to_datetime)
      	end while (current += interval.to_i) <= end_time

      	time_table
      end

			def not_available?(reservation)
        return false if already_taken?(reservation)
        !reservation.user.nil? or reservation.time < DateTime.now or
            @current_user.reservations.count({:recreation => reservation.recreation}) >= reservation.recreation.reservation_settings.slots
      end

      def already_taken?(reservation)
        reservation.user == @current_user
      end
    end

    helpers ReservationHelper
  end
end
