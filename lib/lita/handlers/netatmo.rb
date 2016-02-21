module Lita
  module Handlers
    class Netatmo < Handler
      config :client_id,     type: String, required: true
      config :client_secret, type: String, required: true
      config :username,      type: String, required: true
      config :password,      type: String, required: true

      route /^netatmo air$/, :air, command: false, help: { "netatmo air" => "Fetch sensor data from netatmo." }

      def air(response)
        response.reply build_message(stations_data)
      end

      private

      def build_message(data)
        device = data['body']['devices'].first
        inside  = device['dashboard_data']
        outside = device['modules'].first['dashboard_data']

        message = "[inside] #{inside['Temperature']} °C, #{inside['Humidity']} %, #{inside['Pressure']} hPa, CO2: #{inside['CO2']} ppm\n"
        message += "[outside] #{outside['Temperature']} °C, #{outside['Humidity']} %" if !outside.blank?
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
        redis.setex 'access_token', (auth[:expires_in] - 10), token
        token
      end

      Lita.register_handler(self)
    end
  end
end
