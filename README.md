Rails::Auth
===========
[![Gem Version](https://badge.fury.io/rb/rails-auth.svg)](http://rubygems.org/gems/rails-auth)
[![Build Status](https://travis-ci.org/square/rails-auth.svg?branch=master)](https://travis-ci.org/square/rails-auth)
[![Code Climate](https://codeclimate.com/github/square/rails-auth/badges/gpa.svg)](https://codeclimate.com/github/square/rails-auth)
[![Coverage Status](https://coveralls.io/repos/github/square/rails-auth/badge.svg?branch=master)](https://coveralls.io/github/square/rails-auth?branch=master)
[![Apache 2 licensed](https://img.shields.io/badge/license-Apache2-blue.svg)](https://github.com/square/rails-auth/blob/master/LICENSE)

Modular resource-based authentication and authorization for Rails/Rack

## Description

Rails::Auth is a flexible library designed for both authentication (AuthN) and
authorization (AuthZ) using Rack Middleware. It splits the AuthN and AuthZ
steps into separate middleware classes, using AuthN middleware to first verify
credentials (such as X.509 certificates or cookies), then authorizing the request
via separate AuthZ middleware that consumes these credentials, e.g. access
control lists (ACLs).

Rails::Auth can be used to authenticate and authorize end users using browser
cookies, service-to-service requests using X.509 client certificates, or any
other clients with credentials that have proper authenticating middleware.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-auth

## Usage

To use Rails::Auth you will need to configure the relevant AuthN and AuthZ
middleware for your app.

Rails::Auth ships with the following middleware:

* **AuthN**: `Rails::Auth::X509::Middleware`: support for authenticating
  clients by their SSL/TLS client certificates.
* **AuthZ**: `Rails::Auth::ACL::Middleware`: support for authorizing requests
  using Access Control Lists (ACLs).

Documentation of these middleware and how to use them is provided below.

### Access Control Lists (ACLs)

ACLs are the main tool Rails::Auth provides for AuthZ. ACLs use a set of
route-by-route matchers to control access to particular resources.
Unlike some Rails AuthZ frameworks, this gem grants/denies access to
controller actions, rather than helping you provide different content to
different roles or varying the parameters allowed in, say, an update action.

Rails::Auth encourages the use of YAML files for storing ACL definitions,
although the use of YAML is not mandatory and the corresponding object
structure output from `YAML.load` can be passed in instead. The following is
an example of an ACL definition in YAML:

```yaml
---
- resources:
  - method: ALL
    path: /foo/bar/.*
  allow_x509_subject:
    ou: ponycopter
  allow_claims:
    groups: ["example"]
- resources:
  - method: ALL
    path: /_admin/?.*
  allow_claims:
    groups: ["admins"]
- resources:
  - method: GET
    path: /internal/frobnobs/.*
  allow_x509_subject:
    ou: frobnobber
- resources:
  - method: GET
    path: /
  allow_all: true
```

An ACL consists of a list of guard expressions, each of which contains a list
of resources and a set of predicates which can authorize access to those
resources. *Any* matching predicate will authorize access to any of the
resources listed for a given expression.

Resources are defined by the following constraints:

* **method**: The requested HTTP method, or `"ALL"` to allow any method
* **path**: A regular expression to match the path. `\A` and `\z` are added by
  default to the beginning and end of the regex to ensure the entire path and
  not a substring is matched.

Once you've defined an ACL, you'll need to create a corresponding ACL object
in Ruby and a middleware to authorize requests using that ACL. Add the
following code anywhere you can modify the middleware chain (e.g. config.ru):

```ruby
app = MyRackApp.new

acl = Rails::Auth::ACL.from_yaml(
  File.read("/path/to/my/acl.yaml"),
  matchers: { allow_claims: MyClaimsMatcher }
)

acl_auth = Rails::Auth::ACL::Middleware.new(app, acl: acl)

run acl_auth
```

You'll need to pass in a hash of predicate matchers that correspond to the
keys in the ACL. See the "X.509 Client Certificates" section below for how
to configure the middleware for `allow_x509_subject`.

The following predicate matchers are built-in and always available:

* **allow_all**: (options: `true` or `false`) always allow requests to the
  given resources (so long as `true` is passed as the option)

Custom predicate matchers can be any Ruby class that responds to the `#match`
method. The full Rack environment is passed to `#match`. The corresponding
object from the ACL definition is passed to the class's `#initialize` method.
Here is an example of a simple custom predicate matcher:

```ruby
class MyClaimsMatcher
  def initialize(options)
    @options = options
  end

  def match(env)
    claims = Rails::Auth.credentials(env)["claims"]
    return false unless credential

    @options["groups"].any? { |group| claims["groups"].include?(group) }
  end
end

```

### X.509 Client Certificates

Add an `Rails::Auth::X509::Middleware` object to your Rack middleware chain to
verify X.509 client certificates (in e.g. config.ru):

```ruby
app = MyRackApp.new

acl = Rails::Auth::ACL.from_yaml(
  File.read("/path/to/my/acl.yaml")
  matchers: { allow_x509_subject: Rails::Auth::X509::Matcher }
)

acl_auth = Rails::Auth::ACL::Middleware.new(app, acl: acl)

x509_auth = Rails::Auth::X509::Middleware.new(
  acl_auth,
  ca_file: "/path/to/my/cabundle.pem"
  cert_filters: { 'X-SSL-Client-Cert' => :pem },
  require_cert: true
)

run x509_auth
```

The constructor takes the following parameters:

* **app**: the next Rack middleware in the chain. You'll likely want to use
  an `Rails::Auth::ACL::Middleware` instance as the next middleware in the chain.
* **ca_file**: Path to the certificate authority (CA) bundle with which to
  authenticate clients. This will typically be the certificates for the
  internal CA(s) you use to issue X.509 certificates to internal services, as
  opposed to commercial CAs typically used by browsers. Client certificates
  will be ignored unless they can be verified by one of the CAs in this bundle.
* **cert_filters**: A `Hash` which configures how client certificates are
  extracted from the Rack environment. You will need to configure your web
  server to include the certificate in the Rack environment. See notes below
  for more details.
* **require_cert**: (default `false`) require a valid client cert in order for
  the request to complete. This disallows access to your app from any clients
  who do not have a valid client certificate. When enabled, the middleware
  will raise the `Rails::Auth::X509::CertificateVerifyFailed` exception.

When creating `Rails::Auth::ACL::Middleware`, make sure to pass in
`matchers: { allow_x509_subject: Rails::Auth::X509::Matcher }` in order to use
this predicate in your ACLs. This predicate matcher is not enabled by default.

For client certs to work, you will need to configure your web server to include
them in your Rack environment, and also configure `cert_filters` correctly to
filter and process them from the Rack environment.

For example, if you're using nginx + Passenger, you'll need to add something
like the following to your nginx configuration:

```
passenger_set_cgi_param X-SSL-Client-Cert $ssl_client_raw_cert;
```

Once the client certificate is in the Rack environment in some form, you'll
need to configure a filter object which can convert it from its Rack
environment form into an `OpenSSL::X509::Certificate` instance. There are
two built in filters you can reference as symbols to do this:

* `:pem`: parses certificates from the Privacy Enhanced Mail format
* `:java`:  converts `sun.security.x509.X509CertImpl` object instances

The `cert_filters` parameter is a mapping of Rack environment names to
corresponding filters:

```ruby
cert_filters: { 'X-SSL-Client-Cert' => :pem }
```

In addition to these symbols, a filter can be any object that responds to the
`#call` method, such as a `Proc`. The following filter will parse PEM
certificates:

```ruby
cert_filters: { 'X-SSL-Client-Cert' => proc { |pem| OpenSSL::X509::Certificate.new(pem) } }
```

When certificates are recognized and verified, a `Rails::Auth::X509::Certificate`
object will be added to the Rack environment under `env["rails-auth.credentials"]["x509"]`.
This middleware will never add any certificate to the environment's credentials
that hasn't been verified against the configured CA bundle.

## RSpec integration

Rails::Auth includes built-in matchers that allow you to write tests for your
ACLs to ensure they have the behavior you expect.

To enable RSpec support, require the following:

```ruby
require "rails/auth/rspec"
```

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
    it { is_expected.not_to permit get_request) }
  end
end
```

The following helper methods are available:

* `x509_certificate`, `x509_certificate_hash`: create instance doubles of Rails::Auth::X509::Certificate
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

### Error Page Middleware

When an authorization error occurs, the `Rails::Auth::NotAuthorizedError`
exception is raised up the middleware chain. However, it's likely you would
prefer to show an error page than have an unhandled exception.

You can write your own middleware that catches `Rails::Auth::NotAuthorizedError`
if you'd like. However, a default one is provided which renders a 403 response
with a static page body if you find that helpful.

To use it, add `Rails::Auth::ErrorPage::Middleware` to your app:

```ruby
app = MyRackApp.new

acl = Rails::Auth::ACL.from_yaml(
  File.read("/path/to/my/acl.yaml")
  matchers: { allow_x509_subject: Rails::Auth::X509::Matcher }
)

acl_auth = Rails::Auth::ACL::Middleware.new(app, acl: acl)

x509_auth = Rails::Auth::X509::Middleware.new(
  acl_auth,
  ca_file: "/path/to/my/cabundle.pem"
  cert_filters: { 'X-SSL-Client-Cert' => :pem },
  require_cert: true
)

error_page = Rails::Auth::ErrorPage::Middleware.new(
  x509_auth,
  page_body: File.read("path/to/403.html")
)

run error_page
```

## Contributing

Any contributors to the master *rails-auth* repository must sign the
[Individual Contributor License Agreement (CLA)]. It's a short form that covers
our bases and makes sure you're eligible to contribute.

When you have a change you'd like to see in the master repository, send a
[pull request]. Before we merge your request, we'll make sure you're in the list
of people who have signed a CLA.

[Individual Contributor License Agreement (CLA)]: https://spreadsheets.google.com/spreadsheet/viewform?formkey=dDViT2xzUHAwRkI3X3k5Z0lQM091OGc6MQ&ndplr=1
[pull request]: https://github.com/square/rails-auth/pulls

## License

Copyright (c) 2016 Square Inc. Distributed under the Apache 2.0 License.
See LICENSE file for further details.
