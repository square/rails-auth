Rails::Auth includes RSpec support useful for writing Rails integration tests and/or spec for your ACLs to ensure they have the behavior you expect.

To enable RSpec support, require the following:

```ruby
require "rails/auth/rspec"
```

## Helper Methods

### `with_credentials`: simulate credentials in tests

Configures a `Hash` of credentials (or doubles of them) to be used in the test. Helpful for simulating various scenarios in integration tests:

```ruby
RSpec.describe MyApiController, type: :request do
  describe "#index" do
    let(:example_app) { "foobar" }
    let(:another_app) { "quux" }

    it "permits access to the 'foobar' app" do
      with_credentials(x509: x509_certificate(cn: example_app)) do
        get my_api_path
      end

      expect(response.code).to eq "200"    
    end

    it "disallows the 'quux' app" do
      with_credentials(x509: x509_certificate(cn: another_app)) do
        get my_api_path
      end

      expect(response.code).to eq "403"
    end
  end
end
```

### `x509_certificate`, `x509_certificate_hash`: create X.509 certificate doubles

The `x509_certificate` method creates a [verifying double] of a `Rails::Auth::X509::Certificate`. See the `#with_credentials` example for use in context.

It accepts the following options:

* **cn**: common name of the certificate (e.g. app name or app/host combo)
* **ou**: organizational unit of the certificate (e.g. app name, team name)

The `x509_certificate_hash` method produces a credential hash containing a `Rails::Auth::X509::Certificate`, and is shorthand so you don't have to do `{"x509" => x509_certificate(...)}`. Below is the same example as from `#with_credentials`, but rewritten with the `x509_certificate_hash` shorthand:

```ruby
RSpec.describe MyApiController, type: :request do
  describe "#index" do
    let(:example_app) { "foobar" }
    let(:another_app) { "quux" }

    it "permits access to the 'foobar' app" do
      with_credentials(x509_certificate_hash(cn: example_app)) do
        get my_api_path
      end

      expect(response.code).to eq "200"    
    end

    it "disallows the 'quux' app" do
      with_credentials(x509_certificate_hash(cn: another_app)) do
        get my_api_path
      end

      expect(response.code).to eq "403"
    end
  end
end
```

See also: [[X.509]] Wiki page.

[verifying double]: https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles

## ACL Specs

Rails::Auth provides its own extensions to RSpec to allow you to write specs for the behavior of ACLs.

Below is an example of how to write an ACL spec:

```ruby
RSpec.describe "example_acl.yml", acl_spec: true do
  let(:example_credentials) { x509_certificate_hash(ou: "ponycopter") }

  subject do
    Rails::Auth::ACL.from_yaml(
      File.read("/path/to/example_acl.yml"),
      matchers: { allow_x509_subject: Rails::Auth::X509::Matcher }
    )
  end

  describe "/path/to/resource" do
    it { is_expected.to     permit get_request(credentials: example_credentials) }
    it { is_expected.not_to permit get_request }
  end
end
```

* Request builders: The following methods build requests from the described path:
  * `get_request`
  * `head_request`
  * `put_request`
  * `post_request`
  * `delete_request`
  * `options_request`
  * `path_request`
  * `link_request`
  * `unlink_request`

The following matchers are available:

* `allow_request`: allows a request with the given Rack environment, and optional credentials