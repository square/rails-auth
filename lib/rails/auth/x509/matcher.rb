module Rails
  module Auth
    module X509
      # Predicate matcher for making assertions about X.509 certificates
      class Matcher
        # @option options [String] cn Common Name of the subject
        # @option options [String] ou Organizational Unit of the subject
        def initialize(options)
          @options = options
        end

        # @param [Hash] env Rack environment
        def match(env)
          certificate = Rails::Auth.credentials(env)["x509"]
          return false unless certificate

          @options.all? { |name, value| certificate[name] == value }
        end
      end
    end
  end
end
