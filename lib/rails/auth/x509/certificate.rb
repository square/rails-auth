# frozen_string_literal: true

module Rails
  module Auth
    module X509
      # X.509 client certificates obtained from HTTP requests
      class Certificate
        attr_reader :certificate

        def initialize(certificate)
          unless certificate.is_a?(OpenSSL::X509::Certificate)
            raise TypeError, "expecting OpenSSL::X509::Certificate, got #{certificate.class}"
          end

          @certificate = certificate.freeze
          @subject = {}

          @certificate.subject.to_a.each do |name, data, _type|
            @subject[name.freeze] = data.freeze
          end
          @subject_alt_names = SubjectAltNameExtension.new(certificate)
          @subject_alt_names.freeze
          @subject.freeze
        end

        def [](component)
          @subject[component.to_s.upcase]
        end

        def cn
          @subject["CN"]
        end
        alias common_name cn

        def dns_names
          @subject_alt_names.dns_names
        end

        def ips
          @subject_alt_names.ips
        end

        def ou
          @subject["OU"]
        end
        alias organizational_unit ou

        def uris
          @subject_alt_names.uris
        end

        # According to the SPIFFE standard only one SPIFFE ID can exist in the URI
        # SAN:
        # (https://github.com/spiffe/spiffe/blob/master/standards/X509-SVID.md#2-spiffe-id)
        #
        # @return [String, nil] string containing SPIFFE ID if one is present
        #         in the certificate
        def spiffe_id
          uris.detect { |uri| uri.start_with?("spiffe://") }
        end

        # Generates inspectable attributes for debugging
        #
        # @return [Hash] hash containing parts of the certificate subject (cn, ou)
        #         and subject alternative name extension (uris, dns_names) as well
        #         as SPIFFE ID (spiffe_id), which is just a convenience since those
        #         are already included in the uris
        def attributes
          {
            cn: cn,
            dns_names: dns_names,
            ips: ips,
            ou: ou,
            spiffe_id: spiffe_id,
            uris: uris
          }.reject { |_, v| v.nil? || v.empty? }
        end

        # Compare ourself to another object by ensuring that it has the same type
        # and that its certificate pem is the same as ours
        def ==(other)
          other.is_a?(self.class) && other.certificate.to_der == certificate.to_der
        end

        alias eql? ==
      end
    end
  end
end
