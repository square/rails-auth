RSpec.describe Rails::Auth::ACL do
  let(:example_config) { fixture_path("example_acl.yml").read }

  let(:example_acl) do
    described_class.from_yaml(
      example_config,
      matchers: {
        allow_x509_subject: Rails::Auth::X509::Matcher,
        allow_claims:       ClaimsMatcher
      }
    )
  end

  describe "#match" do
    it "matches routes against the ACL" do
      expect(example_acl.match(env_for(:get, "/"))).to eq true
      expect(example_acl.match(env_for(:get, "/foo/bar/baz"))).to eq true
      expect(example_acl.match(env_for(:get, "/_admin"))).to eq false
    end
  end

  describe "#matching_resources" do
    it "finds Rails::Auth::ACL::Resource objects that match the request" do
      resources = example_acl.matching_resources(env_for(:get, "/foo/bar/baz"))
      expect(resources.first.path).to eq %r{\A/foo/bar/.*\z}
    end
  end
end
