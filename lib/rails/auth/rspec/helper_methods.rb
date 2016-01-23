module Rails
  module Auth
    module RSpec
      # RSpec helper methods
      module HelperMethods
        # Creates an Rails::Auth::X509::Principal instance double
        def x509_principal(cn: nil, ou: nil)
          subject = ""
          subject << "CN=#{cn}" if cn
          subject << "OU=#{ou}" if ou

          instance_double(X509::Principal, subject, cn: cn, ou: ou).tap do |principal|
            allow(principal).to receive(:[]) do |key|
              {
                "CN" => cn,
                "OU" => ou
              }[key.to_s.upcase]
            end
          end
        end

        # Creates a principals hash containing a single X.509 principal instance double
        def x509_principal_hash(**args)
          { "x509" => x509_principal(**args) }
        end

        Rails::Auth::ACL::Resource::HTTP_METHODS.each do |method|
          define_method("#{method.downcase}_request") do |principals: {}|
            path = self.class.description

            # Warn if methods are improperly used
            unless path.chars[0] == "/"
              fail ArgumentError, "expected #{path} to start with '/'"
            end

            env = {
              "REQUEST_METHOD" => method,
              "REQUEST_PATH"   => self.class.description
            }

            principals.each do |type, value|
              Rails::Auth.add_principal(env, type.to_s, value)
            end

            env
          end
        end
      end
    end
  end
end
