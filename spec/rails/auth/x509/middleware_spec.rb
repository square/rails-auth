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
      it "extracts Rails::Auth::Principal::X509 from a PEM certificate in the Rack environment" do
        _response, env = middleware.call(request.merge(example_key => valid_cert_pem))

        principal = Rails::Auth.principals(env).fetch("x509")
        expect(principal).to be_a Rails::Auth::X509::Principal
      end

      it "ignores unverified certificates" do
        _response, env = middleware.call(request.merge(example_key => bad_cert_pem))
        expect(Rails::Auth.principals(env)).to be_empty
      end
    end

    describe "Java certificates" do
      let(:example_key) { "javax.servlet.request.X509Certificate" }
      let(:cert_filter) { :java }

      let(:java_cert) do
        ruby_cert = OpenSSL::X509::Certificate.new(valid_cert_pem)
        Java::SunSecurityX509::X509CertImpl.new(ruby_cert.to_der.to_java_bytes)
      end

      it "extracts Rails::Auth::Principal::X509 from a Java::SunSecurityX509::X509CertImpl" do
        skip "JRuby only" unless defined?(JRUBY_VERSION)

        _response, env = middleware.call(request.merge(example_key => java_cert))

        principal = Rails::Auth.principals(env).fetch("x509")
        expect(principal).to be_a Rails::Auth::X509::Principal
      end
    end
  end

  describe "require_cert: true" do
    let(:cert_required) { true }

    it "functions normally for valid certificates" do
      _response, env = middleware.call(request.merge(example_key => valid_cert_pem))

      principal = Rails::Auth.principals(env).fetch("x509")
      expect(principal).to be_a Rails::Auth::X509::Principal
    end

    it "raises Rails::Auth::X509::CertificateVerifyFailed for unverified certificates" do
      expect do
        middleware.call(request.merge(example_key => bad_cert_pem))
      end.to raise_error Rails::Auth::X509::CertificateVerifyFailed
    end
  end
end
