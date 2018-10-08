# frozen_string_literal: true

module Rails
  module Auth
    module X509
      # Matcher for making assertions about X.509 certificates
      class Matcher
        # @option options [String] cn Common Name of the subject
        # @option options [String] ou Organizational Unit of the subject
        def initialize(options)
          @options = options.freeze
        end

        # @param [Hash] env Rack environment
        def match(env)
          certificate = Rails::Auth.credentials(env)["x509"]
          return false unless certificate

          @options.all? { |name, value| certificate[name] == value }
        end

        # Generates inspectable attributes for debugging
        #
        # @return [Hash] hash containing parts of the certificate subject to match (cn, ou)
        def attributes
          @options
        end
      end
    end
  end
end
