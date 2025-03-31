Rails::Auth was primarily intended for use in environments with the following:

* [Microservices]: Rails::Auth is primarily intended to support environments with many services written as Rails apps which need to make authenticated requests to each other. Square uses Rails::Auth in an environment where we have many Rails microservices (and microservices written in other languages) authenticating to each other with [[X.509]] certificates.
* [Claims-Based Identity]: Rails::Auth is designed to work in conjunction with a central [Single Sign-On] (SSO) system which issues credentials that provide user identities. Rails::Auth does not ship with a specific implementation of an SSO system, but makes it easy to integrate with existing ones.

Below is a comparison of how Rails::Auth relates to the existing landscape of Rails AuthN and AuthZ libraries. These are grouped into two different categories: libraries Rails::Auth replaces, and libraries with which 
Rails::Auth can be used in a complementary fashion.

## Replaces:

* [Warden]: Uses a single "opinionated" Rack middleware providing user-centric authentication and methods that allow controllers to imperatively interrogate the authentication context for authorization purposes. By comparison Rails::Auth is not prescriptive and much more flexible about credential types (supporting credentials for both user and service clients) and uses declarative authorization policies in the form of ACLs.

* [Devise]: A mature, flexible, expansive framework primarily intended for user authentication. Some of the same caveats as Warden apply, however Devise provides a framework for modeling users within a Rails app along with common authentication flows, making it somewhat orthogonal to what Rails::Auth provides. Rails::Auth is designed to easily support [claims-based identity] systems where user identity is outsourced to a separate microservice.

## Complements:

* [Pundit]: Domain object-centric fine-grained authorization using clean object-oriented APIs. Pundit makes authorization decisions around particular objects based on policy objects and contexts. Rails::Auth's credentials can be used as a powerful policy context for Pundit.

* [CanCanCan]: a continuation of the popular CanCan AuthZ library after a period of neglect. Uses a more DSL-like approach to AuthZ than Pundit, but provides many facilities similar to Pundit for domain object-centric
  AuthZ.

[Warden]: https://github.com/hassox/warden/wiki
[Devise]: https://github.com/plataformatec/devise
[Pundit]: https://github.com/elabs/pundit
[CanCanCan]: https://github.com/CanCanCommunity/cancancan

[microservices]: http://martinfowler.com/articles/microservices.html
[claims-based identity]: https://en.wikipedia.org/wiki/Claims-based_identity
[single sign-on]: https://en.wikipedia.org/wiki/Single_sign-on