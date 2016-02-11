require "java"
require "stringio"

module Rails
  module Auth
    module X509
      module Filter
        # Extract OpenSSL::X509::Certificates from Java's sun.security.x509.X509CertImpl
        class Java
          def call(cert)
            OpenSSL::X509::Certificate.new(extract_der(cert)).freeze
          end

          private

          def extract_der(cert)
            stringio = StringIO.new
            cert.derEncode(stringio.to_outputstream)
            stringio.string
          end
        end
      end
    end
  end
end
