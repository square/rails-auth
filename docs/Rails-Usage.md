## Gemfile

Add the following to your Rails app's Gemfile:

```ruby
gem "rails-auth"
```

Then run:

```
$ bundle
```

You should see the `rails-auth` gem be added to your app.

## Configuration

The `Rails::Auth::ConfigBuilder` module contains methods to configure Rails::Auth for various environments. We'll be adding it to `config/application.rb` and environment-specific configs. We'll also need to create an ACL file:

### config/acl.yml

This file contains our app's [[Access Control List|Access Control Lists]]. Here is a starter ACL you can use that allows access to `/` and `/assets`:

```yaml
---
- resources:
  - path: "/"
    method: GET
  - path: "/assets/.*"
    method: GET
  allow_all: true
```

Each time you add new routes to your app, you will have to add them to your ACL and decide how they should be authorized. See [[Access Control Lists]] for more information.

### config/application.rb

```ruby
module MyApp
  class Application < Rails::Application
    [...]

    Rails::Auth::ConfigBuilder.application(config, matchers: { allow_x509_subject: Rails::Auth::X509::Matcher })
  end
end
```

The `application` method accepts the following options:

* **acl_file:** path to the [[Access Control List|Access Control Lists]] file for this app. Defaults to `config/acl.yml`.
* **matchers:** a set of ACL [[matchers]] to use. The above example configures [[X.509]] matchers only.

### config/environments/development.rb

```ruby
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  Rails::Auth::ConfigBuilder.development(config)
end
```

The `development` method accepts the following options:

* **development_credentials:** a hash of simulated credentials to use in the development environment.
* **error_page:** (defaults to `:debug`) enables [[error page middleware|error handling]] for handling AuthZ failures.

### config/environments/test.rb

```ruby
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  Rails::Auth::ConfigBuilder.test(config)
end
```

This middleware takes no options, but configures `Rails.configuration.x.rails_auth.test_credentials` to be injected into the request during tests. This is needed for the [[RSpec Support]]'s `with_credentials` helper method to function correctly.

### config/environments/production.rb

```ruby
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  Rails::Auth::ConfigBuilder.production(
    config,
    cert_filters: { "X-SSL-Client-Cert" => :pem },
    ca_file: "/path/to/your/internal/ca.pem"
  )
end
```

The `production` method accepts the following options:

* **cert_filters**: A `Hash` which configures how client certificates are extracted from the Rack environment. You will need to configure your web server to include the certificate in the Rack environment. See notes below for more details.
* **ca_file**: Path to the certificate authority (CA) bundle with which to authenticate clients. This will typically be the certificates for the internal CA(s) you use to issue [[X.509]] certificates to internal services, as opposed to commercial CAs typically used by browsers. Client certificates will be ignored unless they can be verified by one of the CAs in this bundle.
* **require_cert**: (default `false`) require a valid client cert in order for the request to complete. This disallows access to your app from any clients who do not have a valid client certificate. When enabled, the middleware will raise the `Rails::Auth::X509::CertificateVerifyFailed` exception.
* **error_page:** (defaults to `public/403.html`) renders a static [[error page|error handling]] in the event of an authorization failure. Takes a `Pathname` or `String` path to a static file to render, `:debug` to enable a rich access debugger, or `false` to disable the error page and let the exception bubble up.
* **monitor:** a [[monitor]] proc which is called with the Rack environment and whether or not authorization was successful. Useful for logging and/or for reporting AuthZ failures to an internal monitoring system.

For [[X.509]] client certificate-based authentication to work, you will need to configure your web server to include them in your Rack environment, and also configure `cert_filters` correctly to filter and process them from the Rack environment. Please see the [[X.509]] page for more information on how to configure `cert_filters`.

## Controller Methods

Rails::Auth includes a module of helper methods you can use from Rails controllers. Include them like so:

```ruby
class ApplicationController < ActionController::Base
  # Include this in your ApplicationController
  include Rails::Auth::ControllerMethods
end
```

This defines the following methods:

* `#credentials`: obtain a `HashWithIndifferentAccess` containing all of the credentials that Rails::Auth has extracted using its AuthN middleware.

Below is a larger example of how you can use the `credentials` method in your app:

```ruby
class ApplicationController < ActionController::Base
  # Include this in your ApplicationController
  include Rails::Auth::ControllerMethods

  def x509_certificate_ou
    credentials[:x509].try(:ou)
  end

  def current_username
    # Note: Rails::Auth doesn't provide a middleware to extract this, it's
    # just an example of how you could use it with your own claims-based
    # identity system.
    credentials[:identity_claims].try(:username)
  end
end
```