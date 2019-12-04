# frozen_string_literal: true

require "ostruct"

RSpec.describe Rails::Auth::RSpec::HelperMethods, acl_spec: true do
  let(:example_cn) { "127.0.0.1" }
  let(:example_ou) { "ponycopter" }

  before do
    credentials   = {}
    rails_auth    = double("config", test_credentials: credentials)
    x_config      = double("config", rails_auth: rails_auth)
    configuration = double("config", x: x_config)

    allow(Rails).to receive(:configuration).and_return(configuration)
  end

  describe "#with_credentials" do
    let(:example_credential_type)  { :x509 }
    let(:example_credential_value) { x509_certificate(cn: example_cn, ou: example_ou) }

    it "sets credentials in the Rails config" do
      expect(test_credentials[example_credential_type]).to be_nil

      with_credentials(example_credential_type => example_credential_value) do
        expect(test_credentials[example_credential_type]).to be example_credential_value
      end

      expect(test_credentials[example_credential_type]).to be_nil
    end
  end

  describe "#x509_certificate" do
    subject { x509_certificate(cn: example_cn, ou: example_ou) }

    it "creates instance doubles for Rails::Auth::X509::Certificates" do
      # Method syntax
      expect(subject.cn).to eq example_cn
      expect(subject.ou).to eq example_ou

      # Hash-like syntax
      expect(subject[:cn]).to eq example_cn
      expect(subject[:ou]).to eq example_ou
    end
  end

  describe "#x509_certificate_hash" do
    subject { x509_certificate_hash(cn: example_cn, ou: example_ou) }

    it "creates a certificate hash with an Rails::Auth::X509::Certificate double" do
      expect(subject["x509"].cn).to eq example_cn
    end
  end

  Rails::Auth::ACL::Resource::HTTP_METHODS.each do |method|
    describe "##{method.downcase}_request" do
      it "returns a Rack environment" do
        # These methods introspect self.class.description to find the path
        allow(self.class).to receive(:description).and_return("/")
        env = method("#{method.downcase}_request").call

        expect(env["REQUEST_METHOD"]).to eq method
      end

      it "raises ArgumentError if the description doesn't start with /" do
        expect { method("#{method.downcase}_request").call }.to raise_error(ArgumentError)
      end
    end
  end
end
