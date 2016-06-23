# frozen_string_literal: true

module Rails
  # Modular resource-based authentication and authorization for Rails/Rack
  module Auth
    # Rack environment key for all rails-auth credentials
    CREDENTIALS_ENV_KEY = "rails-auth.credentials".freeze

    # Functionality for storing credentials in the Rack environment
    module Credentials
      # Obtain credentials from a Rack environment
      #
      # @param [Hash] :env Rack environment
      #
      def credentials(env)
        env.fetch(CREDENTIALS_ENV_KEY, {})
      end

      # Add a credential to the Rack environment
      #
      # @param [Hash] :env Rack environment
      # @param [String] :type credential type to add to the environment
      # @param [Object] :credential object to add to the environment
      #
      def add_credential(env, type, credential)
        credentials = env[CREDENTIALS_ENV_KEY] ||= {}

        # Adding a credential is idempotent, so attempting to reregister
        # the same credential should be harmless
        return env if credentials.key?(type) && credentials[type] == credential

        # raise if we already have a cred, but it didn't short-circuit as
        # being == to the one supplied
        raise ArgumentError, "credential #{type} already added to request" if credentials.key?(type)

        credentials[type] = credential

        env
      end
    end

    # Include these functions in Rails::Auth for convenience
    extend Credentials
  end
end
