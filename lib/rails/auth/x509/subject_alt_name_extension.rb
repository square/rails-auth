# frozen_string_literal: true

module Rails
  module Auth
    module X509
      # Provides convenience methods for subjectAltName extension of X.509 certificates
      class SubjectAltNameExtension
        attr_reader :dns_names, :ips, :uris

        DNS_REGEX = /^DNS:/i.freeze
        IP_REGEX  = /^IP( Address)?:/i.freeze
        URI_REGEX = /^URI:/i.freeze

        def initialize(certificate)
          unless certificate.is_a?(OpenSSL::X509::Certificate)
            raise TypeError, "expecting OpenSSL::X509::Certificate, got #{certificate.class}"
          end

          extension = certificate.extensions.detect { |ext| ext.oid == "subjectAltName" }
          values = (extension&.value&.split(",") || []).map(&:strip)

          @dns_names = values.grep(DNS_REGEX) { |v| v.sub(DNS_REGEX, "") }.freeze
          @ips = values.grep(IP_REGEX) { |v| v.sub(IP_REGEX, "") }.freeze
          @uris = values.grep(URI_REGEX) { |v| v.sub(URI_REGEX, "") }.freeze
        end
      end
    end
  end
end
