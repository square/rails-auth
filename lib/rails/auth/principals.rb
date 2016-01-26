# frozen_string_literal: true

module Rails
  # Modular resource-based authentication and authorization for Rails/Rack
  module Auth
    # Rack environment key for all rails-auth principals
    PRINCIPALS_ENV_KEY = "rails-auth.principals".freeze

    # Functionality for storing principals in the Rack environment
    module Principals
      # Obtain principals from a Rack environment
      #
      # @param [Hash] :env Rack environment
      #
      def principals(env)
        env.fetch(PRINCIPALS_ENV_KEY, {})
      end

      # Add a principal to the Rack environment
      #
      # @param [Hash] :env Rack environment
      # @param [String] :type principal type to add to the environment
      # @param [Object] :principal principal object to add to the environment
      #
      def add_principal(env, type, principal)
        principals = env[PRINCIPALS_ENV_KEY] ||= {}

        fail ArgumentError, "principal #{type} already added to request" if principals.key?(type)
        principals[type] = principal
      end
    end

    # Include these functions in Rails::Auth for convenience
    extend Principals
  end
end
