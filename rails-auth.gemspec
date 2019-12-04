# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails/auth/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-auth"
  spec.version       = Rails::Auth::VERSION
  spec.authors       = ["Tony Arcieri"]
  spec.email         = ["tonyarcieri@squareup.com"]
  spec.homepage      = "https://github.com/square/rails-auth/"
  spec.licenses      = ["Apache-2.0"]

  spec.summary       = "Modular resource-oriented authentication and authorization for Rails/Rack"
  spec.description   = <<-DESCRIPTION.strip.gsub(/\s+/, " ")
    A plugin-based framework for supporting multiple authentication and
    authorization systems in Rails/Rack apps. Supports resource-oriented
    route-by-route access control lists with TLS authentication.
  DESCRIPTION

  # Only allow gem to be pushed to https://rubygems.org
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files         = `git ls-files`.split("\n")
  spec.bindir        = "exe"
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_runtime_dependency "rack"

  spec.add_development_dependency "bundler", ">= 1.10", "< 3"
  spec.add_development_dependency "rake", "~> 10.0"
end
