# frozen_string_literal: true

module Rails
  module Auth
    class Credentials
      # A middleware for injecting an arbitrary credentials hash into the Rack environment
      # This is intended for development and testing purposes where you would like to
      # simulate a given X.509 certificate being used in a request or user logged in
      class InjectorMiddleware
        def initialize(app, credentials)
          @app = app
          @credentials = credentials
        end

        def call(env)
          env[Rails::Auth::Env::CREDENTIALS_ENV_KEY] = @credentials
          @app.call(env)
        end
      end
    end
  end
end
