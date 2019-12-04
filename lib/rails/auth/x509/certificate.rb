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

          @subject.freeze
        end

        def [](component)
          @subject[component.to_s.upcase]
        end

        def cn
          @subject["CN"]
        end
        alias common_name cn

        def ou
          @subject["OU"]
        end
        alias organizational_unit ou

        # Generates inspectable attributes for debugging
        #
        # @return [Hash] hash containing parts of the certificate subject (cn, ou)
        def attributes
          {
            cn: cn,
            ou: ou
          }
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
