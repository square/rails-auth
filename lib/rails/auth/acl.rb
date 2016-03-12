# Pull in default predicate matchers
require "rails/auth/acl/matchers/allow_all"

module Rails
  module Auth
    # Route-based access control lists
    class ACL
      # Predicate matchers available by default in ACLs
      DEFAULT_MATCHERS = {
        allow_all: Matchers::AllowAll
      }.freeze

      # Create a Rails::Auth::ACL from a YAML representation of an ACL
      #
      # @param [String] :yaml serialized YAML to load an ACL from
      def self.from_yaml(yaml, **args)
        require "yaml"
        new(YAML.load(yaml), **args)
      end

      # @param [Array<Hash>] :acl Access Control List configuration
      # @param [Hash] :matchers predicate matchers for use with this ACL
      #
      def initialize(acl, matchers: {})
        @resources = []

        acl.each_with_index do |entry|
          resources = entry["resources"]
          raise ParseError, "no 'resources' key present in entry: #{entry.inspect}" unless resources

          predicates = parse_predicates(entry, matchers.merge(DEFAULT_MATCHERS))

          resources.each do |resource|
            @resources << Resource.new(resource, predicates).freeze
          end
        end

        @resources.freeze
      end

      # Match the Rack environment against the ACL, checking all predicates
      #
      # @param [Hash] :env Rack environment
      #
      # @return [Boolean] is the request authorized?
      #
      def match(env)
        @resources.any? { |resource| resource.match(env) }
      end

      # Find all resources that match the ACL. Predicates are *NOT* checked,
      # instead only the initial checks for the "resources" section of the ACL
      # are performed. Use the `#match` method to validate predicates.
      #
      # This method is intended for debugging AuthZ failures. It can find all
      # resources that match the given request so the corresponding predicates
      # can be introspected.
      #
      # @param [Hash] :env Rack environment
      #
      # @return [Array<Rails::Auth::ACL::Resource>] matching resources
      #
      def matching_resources(env)
        @resources.find_all { |resource| resource.match_method_and_path(env) }
      end

      private

      def parse_predicates(entry, matchers)
        predicates = {}

        entry.each do |name, options|
          next if name == "resources"

          matcher_class = matchers[name.to_sym]
          raise ArgumentError, "no matcher for #{name}" unless matcher_class
          raise TypeError, "expected Class for #{name}" unless matcher_class.is_a?(Class)

          predicates[name.freeze] = matcher_class.new(options.freeze).freeze
        end

        predicates.freeze
      end
    end
  end
end
