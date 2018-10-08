# frozen_string_literal: true

RSpec.describe Rails::Auth::Env do
  let(:rack_env)          { Rack::MockRequest.env_for("https://www.example.com") }
  let(:example_authority) { "some-authority" }

  subject(:example_env) { described_class.new(rack_env) }

  it "stores authorization state in the Rack environment" do
    expect(example_env).not_to be_authorized
    expect(example_env.to_rack.key?(described_class::AUTHORIZED_ENV_KEY)).to eq false
    expect(example_env.to_rack.key?(described_class::ALLOWED_BY_ENV_KEY)).to eq false

    example_env.authorize(example_authority)
    expect(example_env).to be_authorized
    expect(example_env.to_rack[described_class::AUTHORIZED_ENV_KEY]).to eq true
    expect(example_env.to_rack[described_class::ALLOWED_BY_ENV_KEY]).to eq example_authority
  end

  it "stores authorizers in the Rack environment" do
    expect(example_env.allowed_by).to be_nil
    expect(example_env.to_rack.key?(described_class::ALLOWED_BY_ENV_KEY)).to eq false

    example_env.allowed_by = example_authority
    expect(example_env.allowed_by).to eq example_authority
    expect(example_env.to_rack[described_class::ALLOWED_BY_ENV_KEY]).to eq example_authority
  end

  # TODO: this could probably be a bit more extensive
  it "stores credentials in the Rack enviroment" do
    expect(example_env.credentials).to be_a Rails::Auth::Credentials
  end
end
