Rails::Auth is designed to support microservice ecosystems identified by [X.509 Certificates](https://en.wikipedia.org/wiki/X.509). This provides strong cryptographic authentication when used in conjunction with [HTTPS](https://en.wikipedia.org/wiki/HTTPS). To use Rails::Auth in this capacity, you will need to set up an internal [certificate authority](https://en.wikipedia.org/wiki/Certificate_authority) (using e.g. [cfssl](https://github.com/cloudflare/cfssl) or [openssl ca](https://www.openssl.org/docs/manmaster/apps/ca.html)) and then create an X.509 certificate for each microservice in your infrastructure.

## ACL Matcher

To enable X.509 support in Rails::Auth, pass in the [[matcher|matchers]] class for X.509 certificates: `Rails::Auth::X509::Matcher` class when creating your [[Access Control List|Access Control Lists]] object, along with a key name you'll use in your ACL like `allow_x509_subject`.

Now when you define your ACL, you can restrict access to particular routes based on the client's X.509 certificate:

```yaml
---
- resources:
  - method: ALL
    path: /foo/bar/.*
  allow_x509_subject:
    ou: ponycopter
```

The following options can be passed to the matcher:

* **cn:** common name of the certificate, e.g. app name or app/host
* **ou:** organizational unit name of the certificate, e.g. app name or team name

## cert_filters

For [[X.509]] client certificate-based authentication to work, you will need to configure your web server to include them in your Rack environment, and also configure `cert_filters` correctly to filter and process them from the Rack environment.

For example, if you're using nginx + Passenger, you'll need to add something like the following to your nginx configuration:

```
passenger_set_cgi_param X-SSL-Client-Cert $ssl_client_raw_cert;
```

Once the client certificate is in the Rack environment in some form, you'll need to configure a filter object which can convert it from its Rack environment form into an `OpenSSL::X509::Certificate` instance. There are
two built in filters you can reference as symbols to do this:

* `:pem`: parses certificates from the Privacy Enhanced Mail format
* `:java`:  converts `sun.security.x509.X509CertImpl` certificate chains

The `cert_filters` parameter is a mapping of Rack environment names to corresponding filters:

```ruby
cert_filters: { "X-SSL-Client-Cert" => :pem }
```

In addition to these symbols, a filter can be any object that responds to the `#call` method, such as a `Proc`. The following filter will parse PEM certificates:

```ruby
cert_filters: {
  "X-SSL-Client-Cert" => proc do |pem|
    OpenSSL::X509::Certificate.new(pem)
  end
}
```

When certificates are recognized and verified, a `Rails::Auth::X509::Certificate` object will be added to the Rack environment under `env["rails-auth.credentials"]["x509"]`. This middleware will never add any certificate to the environment's credentials that hasn't been verified against the configured CA bundle.