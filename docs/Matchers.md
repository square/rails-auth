Matchers are the component of Rails::Auth that make authorization decisions based on credentials. The following matchers are built-in and always available:

The following [[matchers]] are built-in and always available:

* **allow_all**: (options: `true` or `false`) always allow requests to the
  given resources (so long as `true` is passed as the option)

The `Rails::Auth::X509::Matcher` class can be used to make authorization decisions based on X.509 certificates. For more information, see the [[X.509]] Wiki page.

Custom [[matchers]] can be any Ruby class that responds to the `#match` method. The full Rack environment is passed to `#match`. The corresponding object from the ACL definition is passed to the class's `#initialize` method.

Here is an example of a simple custom matcher:

```ruby
class MyClaimsMatcher
  def initialize(options)
    @options = options
  end

  def match(env)
    claims = Rails::Auth.credentials(env)["claims"]
    return false unless credential

    @options["groups"].any? { |group| claims["groups"].include?(group) }
  end
end

```