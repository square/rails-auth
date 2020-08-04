# frozen_string_literal: true

require "logger"

RSpec.describe Rails::Auth::X509::Middleware do
  let(:app)     { ->(env) { [200, env, "Hello, world!"] } }
  let(:request) { Rack::MockRequest.env_for("https://www.example.com") }

  let(:cert_filter) { :pem }
  let(:cert_pem)    { cert_path("valid.crt").read }
  let(:example_key) { "X-SSL-Client-Cert" }

  let(:middleware) do
    described_class.new(
      app,
      cert_filters: { example_key => cert_filter },
      logger: Logger.new(STDERR)
    )
  end

  context "certificate types" do
    describe "PEM certificates" do
      it "extracts Rails::Auth::X509::Certificate from a PEM certificate in the Rack environment" do
        _response, env = middleware.call(request.merge(example_key => cert_pem))

        credential = Rails::Auth.credentials(env).fetch("x509")
        expect(credential).to be_a Rails::Auth::X509::Certificate
      end

      it "normalizes abnormal whitespace" do
        _response, env = middleware.call(request.merge(example_key => cert_pem.tr("\n", "\t")))

        credential = Rails::Auth.credentials(env).fetch("x509")
        expect(credential).to be_a Rails::Auth::X509::Certificate
      end
    end

    # :nocov:
    describe "Java certificates" do
      let(:cert_filter) { :java }
      let(:example_key) { "javax.servlet.request.X509Certificate" }

      let(:java_cert) do
        ruby_cert = OpenSSL::X509::Certificate.new(cert_pem)
        input_stream = Java::JavaIO::ByteArrayInputStream.new(ruby_cert.to_der.to_java_bytes)
        java_cert_klass = Java::JavaSecurityCert::CertificateFactory.getInstance("X.509")
        java_cert_klass.generateCertificate(input_stream)
      end

      it "extracts Rails::Auth::Credential::X509 from a java.security.cert.Certificate" do
        skip "JRuby only" unless defined?(JRUBY_VERSION)

        _response, env = middleware.call(request.merge(example_key => [java_cert]))

        credential = Rails::Auth.credentials(env).fetch("x509")
        expect(credential).to be_a Rails::Auth::X509::Certificate
      end
    end
    # :nocov:
  end
end
