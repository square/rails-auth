module Rails
  # Modular resource-based authentication and authorization for Rails/Rack
  module Auth
    # Rack environment key for marking external authorization
    AUTHORIZED_ENV_KEY = "rails-auth.authorized".freeze

    # Functionality allowing external middleware to override our ACL check process
    module Override
      # Mark a request as externally authorized. Causes ACL checks to be skipped.
      #
      # @param [Hash] :env Rack environment
      #
      def authorized!(env)
        env[AUTHORIZED_ENV_KEY] = true
      end

      # Check whether a request has been externally authorized? Used to bypass
      # ACL check.
      #
      # @param [Hash] :env Rack environment
      #
      def authorized?(env)
        env.fetch(AUTHORIZED_ENV_KEY, false)
      end
    end

    extend Override
  end
end
