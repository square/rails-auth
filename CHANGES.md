### 3.1.0 (2021-10-26)

* [#70](https://github.com/square/rails-auth/pull/70)
  Support URL-encoded PEMs to support new Puma header requirements.
  ([@drcapulet])

### 3.0.0 (2020-08-10)

* [#68](https://github.com/square/rails-auth/pull/68)
  Remove `ca_file` and `require_cert` options to the config builder as we no
  longer verify the certificate chain.
  ([@drcapulet])

* [#67](https://github.com/square/rails-auth/pull/67)
  Remove `ca_file`, `require_cert`, and `truststore` options to X509 middleware
  as we no longer verify the certificate chain.
  ([@drcapulet])

### 2.2.2 (2020-07-02)

* [#65](https://github.com/square/rails-auth/pull/65)
  Fix error when passing `truststore` instead of `ca_file` to X509 middleware.
  ([@drcapulet])

### 2.2.1 (2020-01-08)

* [#63](https://github.com/square/rails-auth/pull/63)
  Fix `FrozenError` in `permit` matcher description.
  ([@drcapulet])

### 2.2.0 (2019-12-05)

* [#55](https://github.com/square/rails-auth/pull/55)
  Allow dynamic injection of credentials.
  ([@drcapulet])

* [#59](https://github.com/square/rails-auth/pull/59)
  Expose X.509 Subject Alternative Name extension
  in the Rails::Auth::X509::Certificate and provide a convenience
  method `spiffe_id` to expose [SPIFFE ID](https://spiffe.io).
  ([@mbyczkowski])

* [#57](https://github.com/square/rails-auth/pull/57)
  Add support for latest versions of Ruby, JRuby and Bundler 2.
  ([@mbyczkowski])

### 2.1.4 (2018-07-12)

* [#51](https://github.com/square/rails-auth/pull/51)
  Fix bug in `permit` custom matcher so that a description is rendered.
  ([@yellow-beard])

### 2.1.3 (2017-08-04)

* [#44](https://github.com/square/rails-auth/pull/44)
  Normalize abnormal whitespace in PEM certificates for Passenger 5.
  ([@drcapulet])

### 2.1.2 (2017-01-27)

* [#42](https://github.com/square/rails-auth/pull/42)
  Don't leak credentials between requests in test / development.
  ([@nerdrew])

### 2.1.1 (2016-09-24)

* [#41](https://github.com/square/rails-auth/pull/41)
  Fix Rails router constraint for checking rails-auth is installed.
  ([@drcapulet])

### 2.1.0 (2016-09-24)

* [#40](https://github.com/square/rails-auth/pull/40)
  Add Rails router constraint for checking rails-auth is installed.
  ([@drcapulet])

### 2.0.3 (2016-07-20)

* [#39](https://github.com/square/rails-auth/pull/39)
  Make credentials idempotent.
  ([@tarcieri])

* [#38](https://github.com/square/rails-auth/pull/38)
  Monitor callback must respond to :call.
  ([@tarcieri])

### 2.0.2 (2016-07-19)

* [#37](https://github.com/square/rails-auth/pull/37)
  Forward #each on Rails::Auth::Credentials and make
  it Enumerable.
  ([@tarcieri])

### 2.0.1 (2016-07-16)

* [#36](https://github.com/square/rails-auth/pull/36)
  Extract Rack environment manipulation into the
  Rails::Auth::Env class.
  ([@tarcieri])

* [#35](https://github.com/square/rails-auth/pull/35)
  Make allowed_by a mandatory argument of
  Rails::Auth.authorized!
  ([@tarcieri])

### 2.0.0 (2016-07-16; yanked in favor of 2.0.1)

* [#34](https://github.com/square/rails-auth/pull/34)
  Rails::Auth.allowed_by stores the matcher used to
  authorize the request in the Rack environment.
  ([@tarcieri])

* [#33](https://github.com/square/rails-auth/pull/33)
  Rails::Auth::Monitor::Middleware provides callbacks
  for authorization success/failure for logging or
  monitoring purposes.
  ([@tarcieri])

* [#32](https://github.com/square/rails-auth/pull/32)
  Rails::Auth::ConfigBuilder provides a simplified config
  API for Rails apps.
  ([@tarcieri])

### 1.3.0 (2016-07-16)

* [#30](https://github.com/square/rails-auth/pull/30)
  Render JSON error responses from Rails::Auth::ErrorPage.
  ([@tarcieri])

### 1.2.0 (2016-07-11)

* [#28](https://github.com/square/rails-auth/pull/28)
  Add a attr_reader for Rails::Auth::ACL#resources.
  ([@tarcieri])

* [#27](https://github.com/square/rails-auth/pull/27)
  Handle javax.servlet.request.X509Certificate arrays.
  ([@tarcieri])

### 1.1.0 (2016-06-23)

* [#26](https://github.com/square/rails-auth/pull/26)
  Make add_credential idempotent.
  ([@ewr])

* [#25](https://github.com/square/rails-auth/pull/25)
  Allow outside middleware to mark a request as authorized.
  ([@ewr])

### 1.0.0 (2016-05-03)

* Initial 1.0 release!

### 0.5.3 (2016-04-28)

* [#22](https://github.com/square/rails-auth/pull/22)
  Use explicit HTTP_METHODS whitelist when 'ALL' method is used.
  ([@tarcieri])

### 0.5.2 (2016-04-27)

* [#21](https://github.com/square/rails-auth/pull/21)
  Send correct Content-Type on ErrorPage middleware.
  ([@tarcieri])

### 0.5.1 (2016-04-24)

* [#20](https://github.com/square/rails-auth/pull/20)
  Handle X5.09 filter exceptions.
  ([@tarcieri])

### 0.5.0 (2016-04-24)

* [#19](https://github.com/square/rails-auth/pull/19)
  Add Rails::Auth::Credentials::InjectorMiddleware.
  ([@tarcieri])

### 0.4.1 (2016-04-23)

* [#17](https://github.com/square/rails-auth/pull/17)
  Use PATH_INFO instead of REQUEST_PATH.
  ([@tarcieri])

* [#15](https://github.com/square/rails-auth/pull/15)
  Check types more thoroughly when parsing ACLs.
  ([@tarcieri])

### 0.4.0 (2016-03-14)

* [#14](https://github.com/square/rails-auth/pull/14)
  Support for optionally matching hostnames in ACL resources.
  ([@tarcieri])

* [#13](https://github.com/square/rails-auth/pull/13)
  Add #attributes method to matchers and X.509 certs.
  ([@tarcieri])

### 0.3.0 (2016-03-12)

* [#12](https://github.com/square/rails-auth/pull/12)
  Add Rails::Auth::ErrorPage::DebugMiddleware.
  ([@tarcieri])

### 0.2.0 (2016-03-11)

* [#10](https://github.com/square/rails-auth/pull/10)
  Add Rails::Auth::ControllerMethods and #credentials method for accessing
  rails-auth.credentials from a Rails controller.
  ([@tarcieri])

### 0.1.0 (2016-02-10)

* [#6](https://github.com/square/rails-auth/pull/6):
  Rename principals to credentials and Rails::Auth::X509::Principals to
  Rails::Auth::X509::Certificates.
  ([@tarcieri])

* [#5](https://github.com/square/rails-auth/pull/5):
  Add Rails::Auth::ErrorPage::Middleware.
  ([@tarcieri])

### 0.0.1 (2016-01-26)

* [#1](https://github.com/square/rails-auth/pull/1):
  Initial implementation.
  ([@tarcieri])

### 0.0.0 (2016-01-04)

* Vaporware release to claim the "rails-auth" gem name


[@drcapulet]: https://github.com/drcapulet
[@ewr]: https://github.com/ewr
[@mbyczkowski]: https://github.com/mbyczkowski
[@nerdrew]: https://github.com/nerdrew
[@tarcieri]: https://github.com/tarcieri
[@yellow-beard]: https://github.com/yellow-beard
