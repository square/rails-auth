# frozen_string_literal: true

# Pull in default matchers
require "rails/auth/acl/matchers/allow_all"

module Rails
  module Auth
    # Route-based access control lists
    class ACL
      attr_reader :resources

      # Matchers available by default in ACLs
      DEFAULT_MATCHERS = {
        allow_all: Matchers::AllowAll
      }.freeze

      # Create a Rails::Auth::ACL from a YAML representation of an ACL
      #
      # @param [String] :yaml serialized YAML to load an ACL from
      def self.from_yaml(yaml, **args)
        require "yaml"
        # rubocop:todo Security/YAMLLoad
        new(YAML.load(yaml), **args)
        # rubocop:enable Security/YAMLLoad
      end

      # @param [Array<Hash>] :acl Access Control List configuration
      # @param [Hash] :matchers authorizers use with this ACL
      #
      def initialize(acl, matchers: {})
        raise TypeError, "expected Array for acl, got #{acl.class}" unless acl.is_a?(Array)

        @resources = []

        acl.each do |entry|
          raise TypeError, "expected Hash for acl entry, got #{entry.class}" unless entry.is_a?(Hash)

          resources = entry["resources"]
          raise ParseError, "no 'resources' key present in entry: #{entry.inspect}" unless resources

          matcher_instances = parse_matchers(entry, matchers.merge(DEFAULT_MATCHERS))

          resources.each do |resource|
            @resources << Resource.new(resource, matcher_instances).freeze
          end
        end

        @resources.freeze
      end

      # Match the Rack environment against the ACL, checking all matchers
      #
      # @param [Hash] :env Rack environment
      #
      # @return [String, nil] name of the first matching matcher, or nil if unauthorized
      #
      def match(env)
        @resources.each do |resource|
          matcher_name = resource.match(env)
          return matcher_name if matcher_name
        end

        nil
      end

      # Find all resources that match the ACL. Matchers are *NOT* checked,
      # instead only the initial checks for the "resources" section of the ACL
      # are performed. Use the `#match` method to validate matchers.
      #
      # This method is intended for debugging AuthZ failures. It can find all
      # resources that match the given request so the corresponding matchers
      # can be introspected.
      #
      # @param [Hash] :env Rack environment
      #
      # @return [Array<Rails::Auth::ACL::Resource>] matching resources
      #
      def matching_resources(env)
        @resources.find_all { |resource| resource.match!(env) }
      end

      private

      def parse_matchers(entry, matchers)
        matcher_instances = {}

        entry.each do |name, options|
          next if name == "resources"

          matcher_class = matchers[name.to_sym]
          raise ArgumentError, "no matcher for #{name}" unless matcher_class
          raise TypeError, "expected Class for #{name}" unless matcher_class.is_a?(Class)

          matcher_instances[name.freeze] = matcher_class.new(options.freeze).freeze
        end

        matcher_instances.freeze
      end
    end
  end
end
