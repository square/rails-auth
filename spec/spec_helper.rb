$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rails/auth"
require "rails/auth/rspec"
require "support/create_certs"
require "support/claims_predicate"
require "pathname"

RSpec.configure(&:disable_monkey_patching!)

def cert_path(name)
  Pathname.new(File.expand_path("../../tmp/certs", __FILE__)).join(name)
end

def fixture_path(*args)
  Pathname.new(File.expand_path("../fixtures", __FILE__)).join(*args)
end

def env_for(method, path)
  {
    "REQUEST_METHOD" => method.to_s.upcase,
    "REQUEST_PATH"   => path
  }
end
