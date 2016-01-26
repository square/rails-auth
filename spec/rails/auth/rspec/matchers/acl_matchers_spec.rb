RSpec.describe "RSpec ACL matchers", acl_spec: true do
  let(:example_principal) { x509_principal_hash(ou: "ponycopter") }
  let(:another_principal) { x509_principal_hash(ou: "derpderp") }

  subject do
    Rails::Auth::ACL.from_yaml(
      fixture_path("example_acl.yml").read,
      matchers: {
        allow_x509_subject: Rails::Auth::X509::Matcher,
        allow_claims:       ClaimsPredicate
      }
    )
  end

  describe "/baz/quux" do
    it { is_expected.to permit get_request(principals: example_principal) }
    it { is_expected.not_to permit get_request(principals: another_principal) }
    it { is_expected.not_to permit get_request }
  end
end
