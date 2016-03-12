# frozen_string_literal: true

module Rails
  module Auth
    module X509
      # Raised when certificate verification is mandatory
      CertificateVerifyFailed = Class.new(NotAuthorizedError)

      # Validates X.509 client certificates and adds credential objects for valid
      # clients to the rack environment as env["rails-auth.credentials"]["x509"]
      class Middleware
        # Create a new X.509 Middleware object
        #
        # @param [Object]               app next app in the Rack middleware chain
        # @param [Hash]                 cert_filters maps Rack environment names to cert extractors
        # @param [String]               ca_file path to the CA bundle to verify client certs with
        # @param [OpenSSL::X509::Store] truststore (optional) provide your own truststore (for e.g. CRLs)
        # @param [Boolean]              require_cert causes middleware to raise if certs are unverified
        #
        # @return [Rails::Auth::X509::Middleware] new X509 middleware instance
        def initialize(app, cert_filters: {}, ca_file: nil, truststore: nil, require_cert: false, logger: nil)
          raise ArgumentError, "no ca_file given" unless ca_file

          @app          = app
          @logger       = logger
          @truststore   = truststore || OpenSSL::X509::Store.new.add_file(ca_file)
          @require_cert = require_cert
          @cert_filters = cert_filters

          @cert_filters.each do |key, filter|
            next unless filter.is_a?(Symbol)

            # Shortcut syntax for symbols
            @cert_filters[key] = Rails::Auth::X509::Filter.const_get(filter.to_s.capitalize).new
          end
        end

        def call(env)
          credential = extract_credential(env)
          Rails::Auth.add_credential(env, "x509".freeze, credential.freeze) if credential

          @app.call(env)
        end

        private

        def extract_credential(env)
          @cert_filters.each do |key, filter|
            raw_cert = env[key]
            next unless raw_cert

            cert = filter.call(raw_cert)
            next unless cert

            if @truststore.verify(cert)
              log("Verified", cert)
              return Rails::Auth::X509::Certificate.new(cert)
            else
              log("Verify FAILED", cert)
              raise CertificateVerifyFailed, "verify failed: #{subject(cert)}" if @require_cert
            end
          end

          raise CertificateVerifyFailed, "no client certificate in request" if @require_cert
          nil
        end

        def log(message, cert)
          @logger.debug("rails-auth: #{message} (#{subject(cert)})") if @logger
        end

        def subject(cert)
          cert.subject.to_a.map { |attr, data| "#{attr}=#{data}" }.join(",")
        end
      end
    end
  end
end
