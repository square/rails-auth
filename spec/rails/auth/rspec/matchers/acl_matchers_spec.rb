# frozen_string_literal: true

RSpec.describe "RSpec ACL matchers", acl_spec: true do
  let(:another_certificate) { x509_certificate_hash(ou: "derpderp") }
  let(:example_certificate) { x509_certificate_hash(ou: "ponycopter") }

  subject do
    Rails::Auth::ACL.from_yaml(
      fixture_path("example_acl.yml").read,
      matchers: {
        allow_x509_subject: Rails::Auth::X509::Matcher,
        allow_claims:       ClaimsMatcher
      }
    )
  end

  describe "/baz/quux" do
    it { is_expected.to permit get_request(credentials: example_certificate) }
    it { is_expected.not_to permit get_request(credentials: another_certificate) }
    it { is_expected.not_to permit get_request }

    it "has the correct description" do
      expect(permit(get_request(credentials: example_certificate)).description)
        .to eq('allow GETs by #<InstanceDouble(Rails::Auth::X509::Certificate) "OU=ponycopter">')
      expect(permit(get_request(credentials: another_certificate)).description)
        .to eq('allow GETs by #<InstanceDouble(Rails::Auth::X509::Certificate) "OU=derpderp">')
      expect(permit(get_request).description)
        .to eq("allow GETs by unauthenticated clients")
    end
  end
end
