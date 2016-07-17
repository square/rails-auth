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
      # @param [String] :allowed_by what allowed the request
      #
      def authorized!(env, allowed_by)
        raise TypeError, "expected string, got #{allowed_by.class}" unless allowed_by.is_a?(String)

        Rails::Auth.set_allowed_by(env, allowed_by) if allowed_by
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
