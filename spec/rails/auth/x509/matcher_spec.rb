RSpec.describe Rails::Auth::X509::Matcher do
  let(:example_cert)      { OpenSSL::X509::Certificate.new(cert_path("valid.crt").read) }
  let(:example_principal) { Rails::Auth::X509::Principal.new(example_cert) }

  let(:example_ou) { "ponycopter" }
  let(:another_ou) { "somethingelse" }

  let(:example_env) do
    { Rails::Auth::PRINCIPALS_ENV_KEY => { "x509" => example_principal } }
  end

  it "matches against a valid Rails::Auth::X509::Principal" do
    predicate = described_class.new(ou: example_ou)
    expect(predicate.match(example_env)).to eq true
  end

  it "doesn't match if the subject mismatches" do
    predicate = described_class.new(ou: another_ou)
    expect(predicate.match(example_env)).to eq false
  end
end
