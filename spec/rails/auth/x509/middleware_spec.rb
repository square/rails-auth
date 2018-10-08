# frozen_string_literal: true

require "logger"

RSpec.describe Rails::Auth::X509::Middleware do
  let(:request) { Rack::MockRequest.env_for("https://www.example.com") }
  let(:app)     { ->(env) { [200, env, "Hello, world!"] } }

  let(:valid_cert_pem) { cert_path("valid.crt").read }
  let(:bad_cert_pem)   { cert_path("invalid.crt").read }
  let(:cert_required)  { false }
  let(:cert_filter)    { :pem }
  let(:example_key)    { "X-SSL-Client-Cert" }

  let(:middleware) do
    described_class.new(
      app,
      logger: Logger.new(STDERR),
      ca_file: cert_path("ca.crt").to_s,
      cert_filters: { example_key => cert_filter },
      require_cert: cert_required
    )
  end

  context "certificate types" do
    describe "PEM certificates" do
      it "extracts Rails::Auth::X509::Certificate from a PEM certificate in the Rack environment" do
        _response, env = middleware.call(request.merge(example_key => valid_cert_pem))

        credential = Rails::Auth.credentials(env).fetch("x509")
        expect(credential).to be_a Rails::Auth::X509::Certificate
      end

      it "ignores unverified certificates" do
        _response, env = middleware.call(request.merge(example_key => bad_cert_pem))
        expect(Rails::Auth.credentials(env)).to be_empty
      end

      it "normalizes abnormal whitespace" do
        _response, env = middleware.call(request.merge(example_key => valid_cert_pem.tr("\n", "\t")))

        credential = Rails::Auth.credentials(env).fetch("x509")
        expect(credential).to be_a Rails::Auth::X509::Certificate
      end
    end

    # :nocov:
    describe "Java certificates" do
      let(:example_key) { "javax.servlet.request.X509Certificate" }
      let(:cert_filter) { :java }

      let(:java_cert) do
        ruby_cert = OpenSSL::X509::Certificate.new(valid_cert_pem)
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

  describe "require_cert: true" do
    let(:cert_required) { true }

    it "functions normally for valid certificates" do
      _response, env = middleware.call(request.merge(example_key => valid_cert_pem))

      credential = Rails::Auth.credentials(env).fetch("x509")
      expect(credential).to be_a Rails::Auth::X509::Certificate
    end

    it "raises Rails::Auth::X509::CertificateVerifyFailed for unverified certificates" do
      expect do
        middleware.call(request.merge(example_key => bad_cert_pem))
      end.to raise_error Rails::Auth::X509::CertificateVerifyFailed
    end
  end
end
