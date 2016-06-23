RSpec.describe Rails::Auth::Credentials do
  describe "#credentials" do
    let(:example_type)        { "example" }
    let(:example_credentials) { { example_type => double(:credential) } }

    let(:example_env) do
      env_for(:get, "/").tap do |env|
        env[Rails::Auth::CREDENTIALS_ENV_KEY] = example_credentials
      end
    end

    it "extracts credentials from Rack environments" do
      expect(Rails::Auth.credentials(example_env)).to eq example_credentials
    end
  end

  describe "#add_credential" do
    let(:example_type)       { "example" }
    let(:example_credential) { double(:credential) }
    let(:example_env)        { env_for(:get, "/") }

    it "adds credentials to a Rack environment" do
      expect(Rails::Auth.credentials(example_env)[example_type]).to be_nil
      Rails::Auth.add_credential(example_env, example_type, example_credential)
      expect(Rails::Auth.credentials(example_env)[example_type]).to eq example_credential
    end

    context "when called twice for the same credential type" do
      let(:second_credential) { double(:credential2) }

      it "succeeds if the credentials are the same" do
        allow(example_credential).to receive(:==).and_return(true)

        Rails::Auth.add_credential(example_env, example_type, example_credential)

        expect do
          Rails::Auth.add_credential(example_env, example_type, second_credential)
        end.to_not raise_error
      end

      it "raises ArgumentError if the credentials are different" do
        allow(example_credential).to receive(:==).and_return(false)

        Rails::Auth.add_credential(example_env, example_type, example_credential)

        expect do
          Rails::Auth.add_credential(example_env, example_type, second_credential)
        end.to raise_error(ArgumentError)
      end
    end
  end
end
