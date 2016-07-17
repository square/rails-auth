# frozen_string_literal: true

require "forwardable"

module Rails
  # Modular resource-based authentication and authorization for Rails/Rack
  module Auth
    # Stores a set of credentials
    class Credentials
      extend Forwardable

      def_delegators :@credentials, :[], :fetch, :empty?, :key?, :to_hash

      def self.from_rack_env(env)
        new(env.fetch(Rails::Auth::Env::CREDENTIALS_ENV_KEY, {}))
      end

      def initialize(credentials = {})
        raise TypeError, "expected Hash, got #{credentials.class}" unless credentials.is_a?(Hash)
        @credentials = credentials
      end

      def []=(type, value)
        raise TypeError, "expected String for type, got #{type.class}" unless type.is_a?(String)
        raise AlreadyAuthorizedError, "credential '#{type}' has already been set" if @credentials.key?(type)
        @credentials[type] = value
      end
    end
  end
end
