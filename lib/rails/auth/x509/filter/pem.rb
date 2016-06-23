module Rails
  module Auth
    module X509
      module Filter
        # Extract OpenSSL::X509::Certificates from Privacy Enhanced Mail (PEM) certificates
        class Pem
          def call(pem)
            OpenSSL::X509::Certificate.new(pem.delete("\t")).freeze
          end
        end
      end
    end
  end
end
