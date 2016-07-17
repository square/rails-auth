Rails::Auth
===========
[![Gem Version](https://badge.fury.io/rb/rails-auth.svg)](http://rubygems.org/gems/rails-auth)
[![Build Status](https://travis-ci.org/square/rails-auth.svg?branch=master)](https://travis-ci.org/square/rails-auth)
[![Code Climate](https://codeclimate.com/github/square/rails-auth/badges/gpa.svg)](https://codeclimate.com/github/square/rails-auth)
[![Coverage Status](https://coveralls.io/repos/github/square/rails-auth/badge.svg?branch=master)](https://coveralls.io/github/square/rails-auth?branch=master)
[![Apache 2 licensed](https://img.shields.io/badge/license-Apache2-blue.svg)](https://github.com/square/rails-auth/blob/master/LICENSE)

Modular resource-based authentication and authorization for Rails/Rack designed
to support [microservice] authentication and [claims-based identity].

[microservice]: http://martinfowler.com/articles/microservices.html
[claims-based identity]: https://en.wikipedia.org/wiki/Claims-based_identity

## Description

Rails::Auth is a flexible library designed for both authentication (AuthN) and authorization (AuthZ) using Rack Middleware. It splits the AuthN and AuthZ
steps into separate middleware classes, using AuthN middleware to first verify credentials (such as X.509 certificates or cookies), then authorizing the request
via separate AuthZ middleware that consumes these credentials, e.g. access control lists (ACLs).

Rails::Auth can be used to authenticate and authorize end users using browser cookies, service-to-service requests using X.509 client certificates, or any
other clients with credentials that have proper authenticating middleware.

Despite what the name may lead you to believe, Rails::Auth also works well with other Rack-based frameworks like Sinatra.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-auth

## Comparison to other Rails/Rack auth libraries/frameworks

For a comparison of Rails::Auth to other Rails auth libraries, including
complimentary libraries and those that Rails::Auth overlaps/competes with,
please see this page on the Wiki:

[Comparison With Other Libraries](https://github.com/square/rails-auth/wiki/Comparison-With-Other-Libraries)

## Documentation

Documentation can be found on the Wiki at: https://github.com/square/rails-auth/wiki

YARD documentation is also available: http://www.rubydoc.info/github/square/rails-auth/master

Please see the following page for how to add Rails::Auth to a Rails app:

[Rails Usage](https://github.com/square/rails-auth/wiki/Rails-Usage)

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
