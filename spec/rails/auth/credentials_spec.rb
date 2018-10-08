# frozen_string_literal: true

RSpec.describe Rails::Auth::Credentials do
  let(:rack_env) { Rack::MockRequest.env_for("https://www.example.com") }

  let(:example_cn) { "127.0.0.1" }
  let(:example_ou) { "ponycopter" }

  let(:example_credential_type)  { "x509" }
  let(:example_credential_value) { instance_double(Rails::Auth::X509::Certificate, cn: example_cn, ou: example_ou) }

  subject(:credentials) { described_class.new(example_credential_type => example_credential_value) }

  describe ".from_rack_env" do
    it "initializes from a Rack environment" do
      expect(described_class.from_rack_env(rack_env)).to be_a described_class
    end
  end

  describe "[]" do
    it "allows hash-like access to credentials" do
      expect(credentials[example_credential_type]).not_to be_blank
    end
  end

  context "when called twice for the same credential type" do
    let(:example_credential) { double(:credential1) }
    let(:second_credential)  { double(:credential2) }

    let(:example_env) { Rack::MockRequest.env_for("https://www.example.com") }

    it "succeeds if the credentials are the same" do
      allow(example_credential).to receive(:==).and_return(true)

      Rails::Auth.add_credential(example_env, example_credential_type, example_credential)

      expect do
        Rails::Auth.add_credential(example_env, example_credential_type, second_credential)
      end.to_not raise_error
    end

    it "raises Rails::Auth::AlreadyAuthorizedError if the credentials are different" do
      allow(example_credential).to receive(:==).and_return(false)

      Rails::Auth.add_credential(example_env, example_credential_type, example_credential)

      expect do
        Rails::Auth.add_credential(example_env, example_credential_type, second_credential)
      end.to raise_error(Rails::Auth::AlreadyAuthorizedError)
    end
  end
end
