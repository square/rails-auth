# frozen_string_literal: true

require "rails/auth/rspec/helper_methods"
require "rails/auth/rspec/matchers/acl_matchers"

RSpec.configure do |config|
  config.include Rails::Auth::RSpec::HelperMethods, acl_spec: true
end
