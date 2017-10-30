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
        return true if in_the_past?(reservation)
        return false if already_taken?(reservation)
        reserved?(reservation) or max_slots_reached?(reservation)
      end

      def max_slots_reached?(reservation)
        @current_user.reservations.today.count({:recreation => reservation.recreation}) >= reservation.recreation.reservation_settings.slots
      end

      def reserved?(reservation)
        !reservation.user.nil?
      end

      def in_the_past?(reservation)
        reservation.time < DateTime.now
      end

      def already_taken?(reservation)
        reservation.user == @current_user
      end

      # validators

      def validate_create(reservation)
        flash.error = 'Maximum reservations made.' if max_slots_reached?(reservation)
        flash.error = 'Cannot make a reservation in the past.' if in_the_past?(reservation)
        flash.error = 'Reservation made by someone else' if reserved?(reservation)
        flash.error = 'Reservation already made.' if already_taken?(reservation)

        flash.next.empty?
      end

      def validate_delete(reservation)
        flash.error = 'Cannot cancel someone else reservation.' unless already_taken?(reservation)
        flash.error = 'Cannot cancel reservation in the past.' if in_the_past?(reservation)

        flash.next.empty?
      end


      def reservation_anchor(reservation)
        "r#{reservation.recreation_id}-#{reservation.time.strftime('%H_%M')}"
      end
    end

    helpers ReservationHelper
  end
end
