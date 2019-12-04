# frozen_string_literal: true

require "coveralls"
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rails/auth"
require "rails/auth/rspec"
require "support/create_certs"
require "support/claims_matcher"
require "pathname"

RSpec.configure(&:disable_monkey_patching!)

def cert_path(name)
  Pathname.new(File.expand_path("../tmp/certs", __dir__)).join(name)
end

def fixture_path(*args)
  Pathname.new(File.expand_path("fixtures", __dir__)).join(*args)
end

def env_for(method, path, host = "127.0.0.1")
  {
    "REQUEST_METHOD" => method.to_s.upcase,
    "PATH_INFO"      => path,
    "HTTP_HOST"      => host
  }
end
