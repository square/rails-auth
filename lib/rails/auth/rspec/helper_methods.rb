# frozen_string_literal: true

module Rails
  module Auth
    module RSpec
      # RSpec helper methods
      module HelperMethods
        # Credentials to be injected into the request during tests
        def test_credentials
          Rails.configuration.x.rails_auth.test_credentials
        end

        # Perform a test with the given credentials
        # NOTE: Credentials will be *cleared* after the block. Nesting is not allowed.
        def with_credentials(credentials = {})
          raise TypeError, "expected Hash of credentials, got #{credentials.class}" unless credentials.is_a?(Hash)

          test_credentials.clear

          credentials.each do |type, value|
            test_credentials[type.to_s] = value
          end
        ensure
          test_credentials.clear
        end

        # Creates an Rails::Auth::X509::Certificate instance double
        def x509_certificate(cn: nil, ou: nil)
          subject = ""
          subject += "CN=#{cn}" if cn
          subject += "OU=#{ou}" if ou

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
          define_method("#{method.downcase}_request") do |credentials: {}|
            path = self.class.description

            # Warn if methods are improperly used
            raise ArgumentError, "expected #{path} to start with '/'" unless path.chars[0] == "/"

            env = {
              "REQUEST_METHOD" => method,
              "PATH_INFO"      => self.class.description
            }

            credentials.each do |type, value|
              Rails::Auth.add_credential(env, type.to_s, value)
            end

            env
          end
        end
      end
    end
  end
end
