# frozen_string_literal: true

RSpec::Matchers.define(:permit) do |env|
  description do
    method      = env["REQUEST_METHOD"]
    credentials = Rails::Auth.credentials(env)
    message     = "allow #{method}s by "

    return message + "unauthenticated clients" if credentials.count.zero?

    message + credentials.values.map(&:inspect).join(", ")
  end

  match { |acl| acl.match(env) }
end
