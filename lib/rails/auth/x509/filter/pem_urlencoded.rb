# frozen_string_literal: true

module Rails
  module Auth
    module X509
      module Filter
        # Extract OpenSSL::X509::Certificates from Privacy Enhanced Mail (PEM) certificates
        # that are URL encoded ($ssl_client_escaped_cert from Nginx).
        class PemUrlencoded < Pem
          def call(encoded_pem)
            super(URI.decode_www_form_component(encoded_pem))
          end
        end
      end
    end
  end
end
