Rails::Auth, despite the name, includes a Rack-only mode which is not dependent on Rails:

```ruby
require "rails/auth/rack"
```

To use Rails::Auth you will need to configure the relevant AuthN and AuthZ middleware for your app.

Rails::Auth ships with the following middleware:

* **AuthN**: `Rails::Auth::X509::Middleware`: support for authenticating clients by their SSL/TLS client certificates. Please see [[X.509]] for more information.
* **AuthZ**: `Rails::Auth::ACL::Middleware`: support for authorizing requests using [[Access Control Lists]] (ACLs).

## ACL Middleware

Once you've defined an [[Access Control List|Access Control Lists]], you'll need to create a corresponding ACL object in Ruby and a middleware to authorize requests using that ACL. Add the following code anywhere you can modify the middleware chain (e.g. config.ru):

```ruby
app = MyRackApp.new

acl = Rails::Auth::ACL.from_yaml(
  File.read("/path/to/my/acl.yaml"),
  matchers: { allow_claims: MyClaimsMatcher }
)

acl_auth = Rails::Auth::ACL::Middleware.new(app, acl: acl)

run acl_auth
```

You'll need to pass in a hash of predicate matchers that correspond to the keys in the ACL.

## X.509 Middleware

Add an `Rails::Auth::X509::Middleware` object to your Rack middleware chain to verify [[X.509]] client certificates (in e.g. config.ru):

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
  cert_filters: { "X-SSL-Client-Cert" => :pem },
  require_cert: true
)

run x509_auth
```

The constructor takes the following parameters:

* **app**: the next Rack middleware in the chain. You'll likely want to use an `Rails::Auth::ACL::Middleware` instance as the next middleware in the chain.
* **ca_file**: Path to the certificate authority (CA) bundle with which to authenticate clients. This will typically be the certificates for the internal CA(s) you use to issue X.509 certificates to internal services, as opposed to commercial CAs typically used by browsers. Client certificates will be ignored unless they can be verified by one of the CAs in this bundle.
* **cert_filters**: A `Hash` which configures how client certificates are extracted from the Rack environment. You will need to configure your web server to include the certificate in the Rack environment. See notes below for more details.
* **require_cert**: (default `false`) require a valid client cert in order for the request to complete. This disallows access to your app from any clients who do not have a valid client certificate. When enabled, the middleware will raise the `Rails::Auth::X509::CertificateVerifyFailed` exception.

When creating `Rails::Auth::ACL::Middleware`, make sure to pass in `matchers: { allow_x509_subject: Rails::Auth::X509::Matcher }` in order to use this predicate in your ACLs. This predicate matcher is not enabled by default.

For client certs to work, you will need to configure your web server to include them in your Rack environment, and also configure `cert_filters` correctly to filter and process them from the Rack environment. For more information on configuring `cert_filters`, see the [[X.509]] Wiki page.

## Error Page Middleware

When an authorization error occurs, the `Rails::Auth::NotAuthorizedError` exception is raised up the middleware chain. However, it's likely you would prefer to show an error page than have an unhandled exception.

You can write your own middleware that catches `Rails::Auth::NotAuthorizedError` if you'd like. However, this library includes two middleware for rescuing this exception for you and displaying an error page.

For more information, see the [[Error Handling]] Wiki page.

#### Rails::Auth::ErrorPage::DebugMiddleware

This middleware displays a detailed error page intended to help debug authorization errors. Please be aware this middleware leaks information about your ACL to a potential attacker. Make sure you're ok with that information being public before using it. If you would like to avoid leaking that information, see `Rails::Auth::ErrorPage::Middleware` below.

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
  cert_filters: { "X-SSL-Client-Cert" => :pem },
  require_cert: true
)

error_page = Rails::Auth::ErrorPage::DebugMiddleware.new(x509_auth, acl: acl)

run error_page
```

#### Rails::Auth::ErrorPage::Middleware

This middleware catches `Rails::Auth::NotAuthorizedError` and renders a given static HTML file, e.g. the 403.html file which ships with Rails. It will not give detailed errors to your users, but it also won't leak information to an attacker.

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
  cert_filters: { "X-SSL-Client-Cert" => :pem },
  require_cert: true
)

error_page = Rails::Auth::ErrorPage::Middleware.new(
  x509_auth,
  page_body: File.read("path/to/403.html")
)

run error_page
```

## Monitor Middleware

`Rails::Auth::Monitor::Middleware` allows you to configure a user-specified callback which is fired each time an authorization decision is made:

```ruby
app = MyRackApp.new

acl = Rails::Auth::ACL.from_yaml(
  File.read("/path/to/my/acl.yaml"),
  matchers: { allow_claims: MyClaimsMatcher }
)

acl_auth = Rails::Auth::ACL::Middleware.new(app, acl: acl)

callback = lambda do |env, success|
  puts "AuthZ result for #{env["PATH_INFO"]}: #{success}" 
end

monitor_middleware = Rails::Auth::Monitor::Middleware.new(acl_auth, callback)

run monitor_middleware
```