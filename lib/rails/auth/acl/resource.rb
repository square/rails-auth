# frozen_string_literal: true

module Rails
  module Auth
    class ACL
      # Rules for a particular route
      class Resource
        attr_reader :http_methods, :path, :predicates

        # Valid HTTP methods
        HTTP_METHODS = %w(GET HEAD PUT POST DELETE OPTIONS PATCH LINK UNLINK).freeze

        # Options allowed for resource matchers
        VALID_OPTIONS = %w(method path).freeze

        # @option :options [String] :method HTTP method allowed ("ALL" for all methods)
        # @option :options [String] :path path to the resource (regex syntax allowed)
        # @param [Hash] :predicates matchers for this resource
        #
        def initialize(options, predicates)
          raise TypeError, "expected Hash for options"    unless options.is_a?(Hash)
          raise TypeError, "expected Hash for predicates" unless predicates.is_a?(Hash)

          unless (extra_keys = options.keys - VALID_OPTIONS).empty?
            raise ParseError, "unrecognized key in ACL resource: #{extra_keys.first}"
          end

          @http_methods = extract_methods(options["method"])
          @path         = /\A#{options.fetch("path")}\z/
          @predicates   = predicates.freeze
        end

        # Match this resource against the given Rack environment, checking all
        # predicates to ensure at least one of them matches
        #
        # @param [Hash] :env Rack environment
        #
        # @return [Boolean] resource and predicates match the given request
        #
        def match(env)
          return false unless match_method_and_path(env)
          @predicates.any? { |_name, predicate| predicate.match(env) }
        end

        # Match *only* the request method/path against the given Rack environment.
        # Predicates are NOT checked.
        #
        # @param [Hash] :env Rack environment
        #
        # @return [Boolean] method and path *only* match the given environment
        #
        def match_method_and_path(env)
          return false unless @http_methods.nil? || @http_methods.include?(env["REQUEST_METHOD".freeze])
          return false unless @path =~ env["REQUEST_PATH".freeze]
          true
        end

        private

        def extract_methods(methods)
          methods = Array(methods)

          return nil if methods.include?("ALL")

          methods.each do |method|
            raise ParseError, "invalid HTTP method: #{method}" unless HTTP_METHODS.include?(method)
          end

          methods.freeze
        end
      end
    end
  end
end
