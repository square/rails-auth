# frozen_string_literal: true

RSpec.describe Rails::Auth::X509::Matcher do
  let(:example_cert)        { OpenSSL::X509::Certificate.new(cert_path("valid.crt").read) }
  let(:example_certificate) { Rails::Auth::X509::Certificate.new(example_cert) }

  let(:example_ou) { "ponycopter" }
  let(:another_ou) { "somethingelse" }

  let(:example_env) do
    { Rails::Auth::Env::CREDENTIALS_ENV_KEY => { "x509" => example_certificate } }
  end

  describe "#match" do
    it "matches against a valid Rails::Auth::X509::Credential" do
      matcher = described_class.new(ou: example_ou)
      expect(matcher.match(example_env)).to eq true
    end

    it "doesn't match if the subject mismatches" do
      matcher = described_class.new(ou: another_ou)
      expect(matcher.match(example_env)).to eq false
    end
  end

  it "knows its attributes" do
    matcher = described_class.new(ou: example_ou)
    expect(matcher.attributes).to eq(ou: example_ou)
  end
end
