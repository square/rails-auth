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

          @dns_names = filtered_names(DNS_REGEX, values)
          @ips = filtered_names(IP_REGEX, values)
          @uris = filtered_names(URI_REGEX, values)
        end

        def filtered_names(regex, values)
          values.grep(regex) { |v| v.sub(regex, "") }.freeze
        end
      end
    end
  end
end
