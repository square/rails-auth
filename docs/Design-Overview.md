Rails::Auth makes use of multiple, independent, single-purpose middleware
classes to handle specific types of AuthN/AuthZ.

## AuthN

Rails::Auth ships with the following AuthN middleware:

* `Rails::Auth::X509::Middleware`: authenticates [[X.509]] certificates obtained
  from the Rack environment.

The goal of Rails::Auth's AuthN middleware is to authenticate *credentials*
taken from the Rack environment and place objects representing them under
the `"rails-auth.credentials"` key within the Rack environment for use by
subsequent AuthN or AuthZ middleware. The built-in support is for X.509
client certificates, but other middleware could handle authentication of
cookies or (OAuth) bearer credentials.

The intended usage is to have multiple AuthN middlewares that are capable
of extracting different types of credentials, but also allowing AuthZ
middleware to apply a single policy to all of them. It's also possible to
chain AuthN middleware together such that one credential obtained earlier
in the middleware stack is used to authenticate another (for e.g.
[channel-bound cookies]).

[channel-bound cookies]: http://www.browserauth.net/channel-bound-cookies

## AuthZ

Rails::Auth ships with one primary AuthZ middleware:

* `Rails::Auth::ACL::Middleware`: support for [[Access Control Lists]] (ACLs).

ACLs let you write a single, declarative policy for authorization in your application. ACLs are pluggable and let you write a single policy which can authorize access using different types of credentials.

ACLs are a declarative approach to authorization, consolidating policies into a single file that can be easily audited by a security team without deep understanding of the many eccentricities of Rails. These policies
provide coarse-grained authorization based on routes (as matched by regexes) and the credentials extracted by the AuthN middleware. However, the do not provide AuthZ which includes specific domain objects, or
policies around them. For that we suggest using a library like [Pundit](https://github.com/elabs/pundit).