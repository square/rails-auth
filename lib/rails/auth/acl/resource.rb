# frozen_string_literal: true

module Rails
  module Auth
    class ACL
      # Rules for a particular route
      class Resource
        attr_reader :http_methods, :path, :host, :matchers

        # Valid HTTP methods
        HTTP_METHODS = %w[GET HEAD PUT POST DELETE OPTIONS PATCH LINK UNLINK].freeze

        # Options allowed for resource matchers
        VALID_OPTIONS = %w[method path host].freeze

        # @option :options [String] :method HTTP method allowed ("ALL" for all methods)
        # @option :options [String] :path path to the resource (regex syntax allowed)
        # @param [Hash] :matchers which matchers are used for this resource
        #
        def initialize(options, matchers)
          raise TypeError, "expected Hash for options"  unless options.is_a?(Hash)
          raise TypeError, "expected Hash for matchers" unless matchers.is_a?(Hash)

          unless (extra_keys = options.keys - VALID_OPTIONS).empty?
            raise ParseError, "unrecognized key in ACL resource: #{extra_keys.first}"
          end

          methods = options["method"] || raise(ParseError, "no 'method' key in resource: #{options.inspect}")
          path    = options["path"]   || raise(ParseError, "no 'path' key in resource: #{options.inspect}")

          @http_methods = extract_methods(methods)
          @path         = /\A#{path}\z/
          @matchers     = matchers.freeze

          # Unlike method and path, host is optional
          host = options["host"]
          @host = /\A#{host}\z/ if host
        end

        # Match this resource against the given Rack environment, checking all
        # matchers to ensure at least one of them matches
        #
        # @param [Hash] :env Rack environment
        #
        # @return [String, nil] name of the matcher which matched, or nil if none matched
        #
        def match(env)
          return nil unless match!(env)

          name, = @matchers.find { |_name, matcher| matcher.match(env) }
          name
        end

        # Match *only* the request method/path/host against the given Rack environment.
        # matchers are NOT checked.
        #
        # @param [Hash] :env Rack environment
        #
        # @return [Boolean] method and path *only* match the given environment
        #
        def match!(env)
          return false unless @http_methods.include?(env["REQUEST_METHOD"])
          return false unless @path =~ env["PATH_INFO"]
          return false unless @host.nil? || @host =~ env["HTTP_HOST"]

          true
        end

        private

        def extract_methods(methods)
          methods = Array(methods)

          return HTTP_METHODS if methods == ["ALL"]
          raise ParseError, "method 'ALL' cannot be used with other methods" if methods.include?("ALL")

          methods.each do |method|
            raise ParseError, "invalid HTTP method: #{method}" unless HTTP_METHODS.include?(method)
          end

          methods.freeze
        end
      end
    end
  end
end
