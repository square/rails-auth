# frozen_string_literal: true

module Rails
  module Auth
    # Wrapper for Rack environments with Rails::Auth helpers
    class Env
      # Rack environment key for marking external authorization
      AUTHORIZED_ENV_KEY = "rails-auth.authorized"

      # Rack environment key for storing what allowed the request
      ALLOWED_BY_ENV_KEY = "rails-auth.allowed-by"

      # Rack environment key for all rails-auth credentials
      CREDENTIALS_ENV_KEY = "rails-auth.credentials"

      attr_reader :allowed_by, :credentials

      # @param [Hash] :env Rack environment
      def initialize(env, credentials: {}, authorized: false, allowed_by: nil)
        raise TypeError, "expected Hash for credentials, got #{credentials.class}" unless credentials.is_a?(Hash)

        @env         = env
        @credentials = Credentials.new(credentials.merge(@env.fetch(CREDENTIALS_ENV_KEY, {})))
        @authorized  = env.fetch(AUTHORIZED_ENV_KEY, authorized)
        @allowed_by  = env.fetch(ALLOWED_BY_ENV_KEY, allowed_by)
      end

      # Check whether a request has been authorized
      def authorized?
        @authorized
      end

      # Mark the environment as authorized to access the requested resource
      #
      # @param [String] :allowed_by label of what allowed the request
      def authorize(allowed_by)
        self.allowed_by = allowed_by
        @authorized = true
      end

      # Set the name of the authority which authorized the request
      #
      # @param [String] :allowed_by label of what allowed the request
      def allowed_by=(allowed_by)
        raise AlreadyAuthorizedError, "already allowed by #{@allowed_by.inspect}" if @allowed_by
        raise TypeError, "expected String for allowed_by, got #{allowed_by.class}" unless allowed_by.is_a?(String)

        @allowed_by = allowed_by
      end

      # Return a Rack environment
      #
      # @return [Hash] Rack environment
      def to_rack
        @env[CREDENTIALS_ENV_KEY] = (@env[CREDENTIALS_ENV_KEY] || {}).merge(@credentials.to_hash)

        @env[AUTHORIZED_ENV_KEY] = @authorized if @authorized
        @env[ALLOWED_BY_ENV_KEY] = @allowed_by if @allowed_by

        @env
      end
    end
  end
end
