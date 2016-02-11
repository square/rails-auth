# frozen_string_literal: true

module Rails
  module Auth
    module X509
      # X.509 client certificates obtained from HTTP requests
      class Certificate
        attr_reader :certificate

        def initialize(certificate)
          unless certificate.is_a?(OpenSSL::X509::Certificate)
            fail TypeError, "expecting OpenSSL::X509::Certificate, got #{certificate.class}"
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
          @subject["CN".freeze]
        end
        alias common_name cn

        def ou
          @subject["OU".freeze]
        end
        alias organizational_unit ou
      end
    end
  end
end
