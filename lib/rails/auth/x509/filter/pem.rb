# frozen_string_literal: true

module Rails
  module Auth
    module X509
      module Filter
        # Extract OpenSSL::X509::Certificates from Privacy Enhanced Mail (PEM) certificates
        class Pem
          def call(pem)
            # Normalize the whitespace in the certificate to the exact format
            # certificates are normally formatted in otherwise parsing with fail
            # with a 'nested asn1 error'. split(" ") handles sequential whitespace
            # characters like \t, \n, and space.
            OpenSSL::X509::Certificate.new(pem.split(" ").instance_eval do
              [[self[0], self[1]].join(" "), self[2...-2], [self[-2], self[-1]].join(" ")]
                .flatten.join("\n")
            end).freeze
          end
        end
      end
    end
  end
end
