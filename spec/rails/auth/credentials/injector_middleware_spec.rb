RSpec.describe Rails::Auth::Credentials::InjectorMiddleware do
  let(:request)     { Rack::MockRequest.env_for("https://www.example.com") }
  let(:app)         { ->(env) { [200, env, "Hello, world!"] } }
  let(:middleware)  { described_class.new(app, credentials) }
  let(:credentials) { { "foo" => "bar" } }

  it "overrides rails-auth credentials in the rack environment" do
    _response, env = middleware.call(request)
    expect(env[Rails::Auth::CREDENTIALS_ENV_KEY]).to eq credentials
  end
end
