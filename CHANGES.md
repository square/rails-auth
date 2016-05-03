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


[@tarcieri]: https://github.com/tarcieri
