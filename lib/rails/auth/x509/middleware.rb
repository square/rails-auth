# frozen_string_literal: true

module Rails
  module Auth
    module X509
      # Extracts X.509 client certificates and adds credential objects to the
      # rack environment as env["rails-auth.credentials"]["x509"]
      class Middleware
        # Create a new X.509 Middleware object
        #
        # @param [Object] app next app in the Rack middleware chain
        # @param [Hash]   cert_filters maps Rack environment names to cert extractors
        # @param [Logger] logger place to log certificate extraction issues
        #
        # @return [Rails::Auth::X509::Middleware] new X509 middleware instance
        def initialize(app, cert_filters: {}, logger: nil)
          @app          = app
          @cert_filters = cert_filters
          @logger       = logger

          @cert_filters.each do |key, filter|
            next unless filter.is_a?(Symbol)

            # Convert snake_case to CamelCase
            filter_name = filter.to_s.split("_").map(&:capitalize).join

            # Shortcut syntax for symbols
            @cert_filters[key] = Rails::Auth::X509::Filter.const_get(filter_name).new
          end
        end

        def call(env)
          credential = extract_credential(env)
          Rails::Auth.add_credential(env, "x509", credential.freeze) if credential

          @app.call(env)
        end

        private

        def extract_credential(env)
          @cert_filters.each do |key, filter|
            cert = extract_certificate_with_filter(filter, env[key])
            next unless cert

            return Rails::Auth::X509::Certificate.new(cert)
          end

          nil
        end

        def extract_certificate_with_filter(filter, raw_cert)
          case raw_cert
          when String   then return if raw_cert.empty?
          when NilClass then return
          end

          filter.call(raw_cert)
        rescue StandardError => e
          @logger.debug("rails-auth: Certificate error: #{e.class}: #{e.message}") if @logger
          nil
        end

        def subject(cert)
          cert.subject.to_a.map { |attr, data| "#{attr}=#{data}" }.join(",")
        end
      end
    end
  end
end
