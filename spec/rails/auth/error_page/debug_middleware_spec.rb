# frozen_string_literal: true

RSpec.describe Rails::Auth::ErrorPage::DebugMiddleware do
  let(:request) { Rack::MockRequest.env_for("https://www.example.com") }

  let(:example_config) { fixture_path("example_acl.yml").read }

  let(:example_acl) do
    Rails::Auth::ACL.from_yaml(
      example_config,
      matchers: {
        allow_x509_subject: Rails::Auth::X509::Matcher,
        allow_claims:       ClaimsMatcher
      }
    )
  end

  subject(:middleware) { described_class.new(app, acl: example_acl) }

  context "access granted" do
    let(:code) { 200 }
    let(:app)  { ->(env) { [code, env, "Hello, world!"] } }

    it "renders the expected response" do
      response = middleware.call(request)
      expect(response.first).to eq code
    end
  end

  context "access denied" do
    let(:app) { ->(_env) { raise(Rails::Auth::NotAuthorizedError, "not authorized!") } }

    it "renders the error page" do
      code, _env, body = middleware.call(request)
      expect(code).to eq 403
      expect(body.join).to include("Access Denied")
    end
  end
end
