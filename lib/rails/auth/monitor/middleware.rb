# frozen_string_literal: true

module Rails
  module Auth
    module Monitor
      # Fires a user-specified callback which reports on authorization success
      # or failure. Useful for logging or monitoring systems for AuthZ failures
      class Middleware
        def initialize(app, callback)
          raise ArgumentError, "callback must respond to :call" unless callback.respond_to?(:call)

          @app      = app
          @callback = callback
        end

        def call(env)
          begin
            result = @app.call(env)
          rescue Rails::Auth::NotAuthorizedError
            @callback.call(env, false)
            raise
          end

          @callback.call(env, true)
          result
        end
      end
    end
  end
end
