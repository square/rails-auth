# frozen_string_literal: true

RSpec.describe Rails::Auth::X509::SubjectAltNameExtension do
  let(:example_cert) { OpenSSL::X509::Certificate.new(cert_path("valid.crt").read) }
  let(:example_cert_with_extension) { OpenSSL::X509::Certificate.new(cert_path("valid_with_ext.crt").read) }
  let(:extension_for_cert) { described_class.new(example_cert) }
  let(:extension_for_cert_with_san) { described_class.new(example_cert_with_extension) }
  let(:example_dns_names) { %w[example.com exemplar.com somethingelse.com] }
  let(:example_ips) { %w[0.0.0.0 127.0.0.1 192.168.1.1] }
  let(:example_uris) { %w[spiffe://example.com/exemplar https://www.example.com/page1 https://www.example.com/page2] }

  describe "for cert without extensions" do
    it "returns no DNS names" do
      expect(extension_for_cert.dns_names).to be_empty
    end

    it "returns no IPs" do
      expect(extension_for_cert.ips).to be_empty
    end

    it "returns no URIs" do
      expect(extension_for_cert.uris).to be_empty
    end
  end

  describe "for cert with extensions" do
    it "knows its DNS names" do
      expect(extension_for_cert_with_san.dns_names).to eq example_dns_names
    end

    it "knows its IPs" do
      expect(extension_for_cert_with_san.ips).to eq example_ips
    end

    it "knows its URIs" do
      expect(extension_for_cert_with_san.uris).to eq example_uris
    end
  end
end
