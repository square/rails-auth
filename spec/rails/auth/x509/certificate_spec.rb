# frozen_string_literal: true

RSpec.describe Rails::Auth::X509::Certificate do
  let(:example_cert) { OpenSSL::X509::Certificate.new(cert_path("valid.crt").read) }
  let(:example_cert_with_extension) { OpenSSL::X509::Certificate.new(cert_path("valid_with_ext.crt").read) }
  let(:example_certificate) { described_class.new(example_cert) }
  let(:example_certificate_with_extension) { described_class.new(example_cert_with_extension) }

  let(:example_cn) { "127.0.0.1" }
  let(:example_dns_names) { %w[example.com exemplar.com somethingelse.com] }
  let(:example_ips) { %w[0.0.0.0 127.0.0.1 192.168.1.1] }
  let(:example_ou) { "ponycopter" }
  let(:example_spiffe) { "spiffe://example.com/exemplar" }
  let(:example_uris) { [example_spiffe, "https://www.example.com/page1", "https://www.example.com/page2"] }

  describe "without extensions" do
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

    it "has no #dns_names" do
      expect(example_certificate.dns_names).to be_empty
    end

    it "has no #ips" do
      expect(example_certificate.ips).to be_empty
    end

    it "knows its #ou" do
      expect(example_certificate.ou).to eq example_ou
    end

    it "has no #uris" do
      expect(example_certificate.uris).to be_empty
    end

    it "has no #spiffe_id" do
      expect(example_certificate.spiffe_id).to be_nil
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

  describe "with extensions" do
    describe "#[]" do
      it "allows access to subject components via strings" do
        expect(example_certificate_with_extension["CN"]).to eq example_cn
        expect(example_certificate_with_extension["OU"]).to eq example_ou
      end

      it "allows access to subject components via symbols" do
        expect(example_certificate_with_extension[:cn]).to eq example_cn
        expect(example_certificate_with_extension[:ou]).to eq example_ou
      end
    end

    it "knows its #cn" do
      expect(example_certificate_with_extension.cn).to eq example_cn
    end

    it "knows its #dns_names" do
      expect(example_certificate_with_extension.dns_names).to eq example_dns_names
    end

    it "knows its #ips" do
      expect(example_certificate_with_extension.ips).to eq example_ips
    end

    it "knows its #ou" do
      expect(example_certificate_with_extension.ou).to eq example_ou
    end

    it "knows its #spiffe_id" do
      expect(example_certificate_with_extension.spiffe_id).to eq example_spiffe
    end

    it "knows its #uris" do
      expect(example_certificate_with_extension.uris).to eq example_uris
    end

    it "knows its attributes" do
      expected_attrs = {
        cn: example_cn,
        dns_names: example_dns_names,
        ips: example_ips,
        ou: example_ou,
        spiffe_id: example_spiffe,
        uris: example_uris
      }
      expect(example_certificate_with_extension.attributes).to eq(expected_attrs)
    end

    it "compares certificate objects by comparing their certificates" do
      second_cert = OpenSSL::X509::Certificate.new(cert_path("valid_with_ext.crt").read)
      second_certificate = described_class.new(second_cert)

      expect(example_certificate_with_extension).to be_eql second_certificate
    end
  end
end
