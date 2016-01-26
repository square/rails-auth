RSpec.describe Rails::Auth::X509::Principal do
  let(:example_cert)      { OpenSSL::X509::Certificate.new(cert_path("valid.crt").read) }
  let(:example_principal) { described_class.new(example_cert) }

  let(:example_cn) { "127.0.0.1" }
  let(:example_ou) { "ponycopter" }

  describe "#[]" do
    it "allows access to subject components via strings" do
      expect(example_principal["CN"]).to eq example_cn
      expect(example_principal["OU"]).to eq example_ou
    end

    it "allows access to subject components via symbols" do
      expect(example_principal[:cn]).to eq example_cn
      expect(example_principal[:ou]).to eq example_ou
    end
  end

  it "knows its #cn" do
    expect(example_principal.cn).to eq example_cn
  end

  it "knows its #ou" do
    expect(example_principal.ou).to eq example_ou
  end
end
