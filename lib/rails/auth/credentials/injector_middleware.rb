module Rails
  module Auth
    module Credentials
      # A middleware for injecting an arbitrary credentials hash into the Rack environment
      # This is intended for development and testing purposes where you would like to
      # simulate a given X.509 certificate being used in a request or user logged in
      class InjectorMiddleware
        def initialize(app, credentials)
          @app = app
          @credentials = credentials
        end

        def call(env)
          env[Rails::Auth::CREDENTIALS_ENV_KEY] = @credentials
          @app.call(env)
        end
      end
    end
  end
end
