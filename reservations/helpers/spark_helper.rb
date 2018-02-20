require 'net/http'
require 'json'

module Recreations
  class Reservations
    module SparkHelper

      def schedule_notification(reservation)
        scheduler = self.class.scheduler
        notifier = Recreations::SparkNotifier.new(reservation.id)
        hash_tag = reservation.hash

        scheduler.at reservation.time.advance({:minutes => -5}).strftime("%T"), notifier, {:tag => hash_tag}
      end

      def unschedule_notification(reservation)
        scheduler = self.class.scheduler
        hash_tag = reservation.hash

        jobs = scheduler.jobs({:tag => hash_tag})
        jobs.each(&:unschedule)
      end

    end

    helpers SparkHelper
  end

  class SparkNotifier

    @@spark_uri = URI.parse("https://api.ciscospark.com/v1/messages")

    def initialize(reservation_id)
      @reservation_id = reservation_id
    end

    def call
      notify if available
    end

    private

    def reservation
      @reservation ||= Reservation.get(@reservation_id)
    end

    def spark_bot_auth_code
      @spark_bot_auth_code ||= Settings.first.spark_bot_auth_code
    end

    def notify
      auth_code = spark_bot_auth_code
      email = reservation.user.email
      name = reservation.recreation.name
      Net::HTTP.start(@@spark_uri.host, @@spark_uri.port, {:use_ssl => @@spark_uri.scheme == 'https'}) do |https|
        request = Net::HTTP::Post.new(@@spark_uri, {
            'Content-Type' => 'application/json; charset=utf-8',
            'Authorization' => "Bearer #{auth_code}"
        })
        request.body = {
            :toPersonEmail => email,
            :text => "You have reservation for #{name} in 5 minutes."
        }.to_json

        https.request(request)
      end
    rescue => e
      puts "something went wrong when notifying: " + e.to_s
    end

    def available
      reservation.user.email.present? and reservation.user.spark_integration and spark_bot_auth_code.present?
    end

  end
end
