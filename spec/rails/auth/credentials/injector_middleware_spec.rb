# frozen_string_literal: true

RSpec.describe Rails::Auth::Credentials::InjectorMiddleware do
  let(:request)     { Rack::MockRequest.env_for("https://www.example.com") }
  let(:app)         { ->(env) { [200, env, "Hello, world!"] } }
  let(:middleware)  { described_class.new(app, credentials) }
  let(:credentials) { { "foo" => "bar" } }

  it "overrides rails-auth credentials in the rack environment" do
    _response, env = middleware.call(request)
    expect(env[Rails::Auth::Env::CREDENTIALS_ENV_KEY]).to eq credentials
  end

  context "with a proc for credentials" do
    let(:credentials_proc) { instance_double(Proc) }
    let(:middleware)       { described_class.new(app, credentials_proc) }

    it "overrides rails-auth credentials in the rack environment" do
      expect(credentials_proc).to receive(:call).with(request).and_return(credentials)

      _response, env = middleware.call(request)

      expect(env[Rails::Auth::Env::CREDENTIALS_ENV_KEY]).to eq credentials
    end
  end
end
