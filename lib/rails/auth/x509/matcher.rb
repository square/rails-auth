module Rails
  module Auth
    module X509
      # Predicate matcher for making assertions about X.509 principals
      class Matcher
        # @option options [String] cn Common Name of the subject
        # @option options [String] ou Organizational Unit of the subject
        def initialize(options)
          @options = options
        end

        # @param [Hash] env Rack environment
        def match(env)
          principal = Rails::Auth.principals(env)["x509"]
          return false unless principal

          @options.all? { |name, value| principal[name] == value }
        end
      end
    end
  end
end
