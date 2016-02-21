require 'oauth2'

module Lita
  module Handlers
    class Netatmo < Handler
      config :client_id,     type: String, required: true
      config :client_secret, type: String, required: true
      config :username,      type: String, required: true
      config :password,      type: String, required: true
      config :city,          type: String, required: false

      route /^netatmo$/, :all, command: false, help: { "netatmo" => "Fetch sensor data from netatmo." }
      def all(response)
        response.reply build_message(stations_data, 'all')
      end

      route /^netatmo (air|co2)$/, :air, command: false, help: { "netatmo air|co2" => "Fetch sensor co2 data from netatmo." }
      def air(response)
        response.reply build_message(stations_data, 'air')
      end
      route /^netatmo temperature$/, :temperature, command: false, help: { "netatmo temperature" => "Fetch sensor temperature data from netatmo." }
      def temperature(response)
        response.reply build_message(stations_data, 'temperature')
      end
      route /^netatmo humidity$/, :humidity, command: false, help: { "netatmo humidity" => "Fetch sensor humidity data from netatmo." }
      def humidity(response)
        response.reply build_message(stations_data, 'humidity')
      end
      route /^netatmo pressure$/, :pressure, command: false, help: { "netatmo pressure" => "Fetch sensor pressure data from netatmo." }
      def pressure(response)
        response.reply build_message(stations_data, 'pressure')
      end

      private

      def build_message(data, type)
        device = data['body']['devices'].first
        inside  = device['dashboard_data']
        outside = device['modules'].first['dashboard_data']

        case type
        when /^air|co2$/i
          message = "CO2: #{inside['CO2']} ppm"
        when /^temperature$/i
          message = "[inside] #{inside['Temperature']} °C\n"
          message += "[outside] #{outside['Temperature']} °C" if outside.is_a?(Hash)
        when /^pressure$/i
          message = "[inside] #{inside['Pressure']} hPa\n"
        when /^humidity$/i
          message = "[inside] humidity : #{inside['Humidity']} %\n"
          message += "[outside] humidity : #{outside['Humidity']} %" if outside.is_a?(Hash)
        else
          message = "[inside] #{inside['Temperature']} °C, humidity : #{inside['Humidity']} %, #{inside['Pressure']} hPa, CO2: #{inside['CO2']} ppm\n"
          message += "[outside] #{outside['Temperature']} °C, humidity : #{outside['Humidity']} %" if outside.is_a?(Hash)
        end

        message
      end

      # https://dev.netatmo.com/doc/methods/getstationsdata
      def stations_data
        response = http.get 'https://api.netatmo.com/api/getstationsdata', access_token: access_token
        MultiJson.load(response.body)
      end

      def access_token
        token = redis.get 'access_token'
        return token if token

        client = OAuth2::Client.new(config.client_id, config.client_secret, :site => 'https://api.netatmo.net/')
        client.options= {:authorize_url=>'/oauth2/authorize', :token_url=>'/oauth2/token', :token_method=>:post, :connection_opts=>{}, :max_redirects=>5, :raise_errors=>true}
        token = client.password.get_token(config.username, config.password)

        auth  = token.to_hash
        token = auth[:access_token]
        puts redis.setex('access_token', (auth['expire_in'] - 10), token)

        token
      end

      Lita.register_handler(self)
    end
  end
end
