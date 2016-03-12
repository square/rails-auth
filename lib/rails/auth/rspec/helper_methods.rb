module Rails
  module Auth
    module RSpec
      # RSpec helper methods
      module HelperMethods
        # Creates an Rails::Auth::X509::Certificate instance double
        def x509_certificate(cn: nil, ou: nil)
          subject = ""
          subject << "CN=#{cn}" if cn
          subject << "OU=#{ou}" if ou

          instance_double(Rails::Auth::X509::Certificate, subject, cn: cn, ou: ou).tap do |certificate|
            allow(certificate).to receive(:[]) do |key|
              {
                "CN" => cn,
                "OU" => ou
              }[key.to_s.upcase]
            end
          end
        end

        # Creates a certificates hash containing a single X.509 certificate instance double
        def x509_certificate_hash(**args)
          { "x509" => x509_certificate(**args) }
        end

        Rails::Auth::ACL::Resource::HTTP_METHODS.each do |method|
          define_method("#{method.downcase}_request") do |certificates: {}|
            path = self.class.description

            # Warn if methods are improperly used
            unless path.chars[0] == "/"
              raise ArgumentError, "expected #{path} to start with '/'"
            end

            env = {
              "REQUEST_METHOD" => method,
              "REQUEST_PATH"   => self.class.description
            }

            certificates.each do |type, value|
              Rails::Auth.add_credential(env, type.to_s, value)
            end

            env
          end
        end
      end
    end
  end
end
