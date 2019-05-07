# Helper methods defined here can be accessed in any controller or view in the application

module Recreations
  class Reservations
    module ReservationHelper
      
      def create_time_table(time_interval, start_time, end_time)
				interval = Time.gm(1970, 1, 1, time_interval.hour, time_interval.min, time_interval.sec)
      	time_table = []
      	current = start_time
      	begin
      		time_table.push(current.to_datetime)
      	end while (current += interval.to_i) <= end_time

      	time_table
      end

			def not_available?(reservation)
        return true if in_the_past?(reservation)
        return false if taken_by_me?(reservation)
        reserved?(reservation) or max_slots_reached?(reservation)
      end

      def max_slots_reached?(reservation)
        @current_user.reservations.count({:recreation => reservation.recreation, :time.gte => Time.now.beginning_of_day}) >= reservation.recreation.reservation_settings.slots
      end

      def reserved?(reservation)
        !reservation.user.nil?
      end

      def in_the_past?(reservation)
        reservation.time < DateTime.now
      end

      def taken_by_me?(reservation)
        reservation.user == @current_user
      end

      def participant?(reservation)
        !reservation.participations.first(:user => @current_user).nil?
      end

      def delete_action?(reservation)
        taken_by_me?(reservation) || participant?(reservation)
      end

      # validators

      def validate_create(reservation)
        flash.error = 'Maximum reservations made.' if max_slots_reached?(reservation)
        flash.error = 'Cannot make a reservation in the past.' if in_the_past?(reservation)
        flash.error = 'Reservation made by someone else' if reserved?(reservation)
        flash.error = 'Reservation already made.' if taken_by_me?(reservation)

        flash.next.empty?
      end

      def validate_delete(reservation)
        flash.error = 'Cannot cancel someone else reservation.' unless taken_by_me?(reservation)
        flash.error = 'Cannot cancel reservation in the past.' if in_the_past?(reservation)

        flash.next.empty?
      end


      def reservation_anchor(reservation)
        "r#{reservation.recreation_id}-#{reservation.time.strftime('%H_%M')}"
      end

      def permalink_for(str)
        str.gsub(/[^\w\/]|[!\(\)\.]+/, ' ').strip.downcase.gsub(/\ +/, '-')
      end
    end

    helpers ReservationHelper
  end
end
