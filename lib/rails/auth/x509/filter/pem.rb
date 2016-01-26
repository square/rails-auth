module Rails
  module Auth
    module X509
      module Filter
        # Support for extracting X509::Principals from Privacy Enhanced Mail (PEM) certificates
        class Pem
          def call(pem)
            OpenSSL::X509::Certificate.new(pem).freeze
          end
        end
      end
    end
  end
end
