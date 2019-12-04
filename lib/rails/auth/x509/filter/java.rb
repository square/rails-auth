# frozen_string_literal: true

module Rails
  module Auth
    module X509
      module Filter
        # Extract OpenSSL::X509::Certificates from java.security.cert.Certificate
        class Java
          def call(certs)
            return if certs.nil? || certs.empty?

            OpenSSL::X509::Certificate.new(certs[0].get_encoded).freeze
          end
        end
      end
    end
  end
end
