RSpec.describe Rails::Auth::Principals do
  describe "#principals" do
    let(:example_type)       { "example" }
    let(:example_principals) { { example_type => double(:principal) } }

    let(:example_env) do
      env_for(:get, "/").tap do |env|
        env[Rails::Auth::PRINCIPALS_ENV_KEY] = example_principals
      end
    end

    it "extracts principals from Rack environments" do
      expect(Rails::Auth.principals(example_env)).to eq example_principals
    end
  end

  describe "#add_principal" do
    let(:example_type)      { "example" }
    let(:example_principal) { double(:principal) }
    let(:example_env)       { env_for(:get, "/") }

    it "adds principals to a Rack environment" do
      expect(Rails::Auth.principals(example_env)[example_type]).to be_nil
      Rails::Auth.add_principal(example_env, example_type, example_principal)
      expect(Rails::Auth.principals(example_env)[example_type]).to eq example_principal
    end

    it "raises ArgumentError if the same type of principal is added twice" do
      Rails::Auth.add_principal(example_env, example_type, example_principal)

      expect do
        Rails::Auth.add_principal(example_env, example_type, example_principal)
      end.to raise_error(ArgumentError)
    end
  end
end
