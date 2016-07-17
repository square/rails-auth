module Rails
  # Modular resource-based authentication and authorization for Rails/Rack
  module Auth
    # Rack environment key for storing what allowed the request
    ALLOWED_BY_ENV_KEY = "rails-auth.allowed-by".freeze

    # Functionality for storing AuthZ results in the environment
    module Result
      # Mark what authorized the request
      #
      # @param [Hash] :env Rack environment
      # @param [String] :allowed_by what allowed this request
      def set_allowed_by(env, allowed_by)
        env[ALLOWED_BY_ENV_KEY] = allowed_by
      end

      # Read what authorized the request
      #
      # @param [Hash] :env Rack environment
      #
      # @return [String, nil] what authorized the request
      def allowed_by(env)
        env[ALLOWED_BY_ENV_KEY]
      end
    end

    extend Result
  end
end
