# frozen_string_literal: true

require "forwardable"

module Rails
  # Modular resource-based authentication and authorization for Rails/Rack
  module Auth
    # Stores a set of credentials
    class Credentials
      extend Forwardable
      include Enumerable

      def_delegators :@credentials, :fetch, :empty?, :key?, :each, :to_hash, :values

      def self.from_rack_env(env)
        new(env.fetch(Rails::Auth::Env::CREDENTIALS_ENV_KEY, {}))
      end

      def initialize(credentials = {})
        raise TypeError, "expected Hash, got #{credentials.class}" unless credentials.is_a?(Hash)

        @credentials = credentials
      end

      def []=(type, value)
        return if @credentials.key?(type) && @credentials[type] == value
        raise TypeError, "expected String for type, got #{type.class}" unless type.is_a?(String)
        raise AlreadyAuthorizedError, "credential '#{type}' has already been set" if @credentials.key?(type)

        @credentials[type] = value
      end

      def [](type)
        @credentials[type.to_s]
      end
    end
  end
end
