RSpec.describe Rails::Auth::X509::Certificate do
  let(:example_cert) { OpenSSL::X509::Certificate.new(cert_path("valid.crt").read) }
  let(:example_certificate) { described_class.new(example_cert) }

  let(:example_cn) { "127.0.0.1" }
  let(:example_ou) { "ponycopter" }

  describe "#[]" do
    it "allows access to subject components via strings" do
      expect(example_certificate["CN"]).to eq example_cn
      expect(example_certificate["OU"]).to eq example_ou
    end

    it "allows access to subject components via symbols" do
      expect(example_certificate[:cn]).to eq example_cn
      expect(example_certificate[:ou]).to eq example_ou
    end
  end

  it "knows its #cn" do
    expect(example_certificate.cn).to eq example_cn
  end

  it "knows its #ou" do
    expect(example_certificate.ou).to eq example_ou
  end

  it "knows its attributes" do
    expect(example_certificate.attributes).to eq(cn: example_cn, ou: example_ou)
  end

  it "compares certificate objects by comparing their certificates" do
    second_cert = OpenSSL::X509::Certificate.new(cert_path("valid.crt").read)
    second_certificate = described_class.new(second_cert)

    expect(example_certificate).to be_eql second_certificate
  end
end
