RSpec::Matchers.define(:permit) do |env|
  description do
    method     = env["REQUEST_METHOD"]
    principals = Rails::Auth.principals(env)
    message    = "allow #{method}s by "

    return message << "unauthenticated clients" if principals.count.zero?

    message << principals.values.map(&:inspect).join(", ")
  end

  match { |acl| acl.match(env) }
end
