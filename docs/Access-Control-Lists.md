Access Control Lists (ACLs) are the main tool Rails::Auth provides for AuthZ. ACLs use a set of route-by-route [[matchers]] to control access to particular resources.

Rails::Auth encourages the use of YAML files for storing ACL definitions, although the use of YAML is not mandatory and the corresponding object structure output from `YAML.load` can be passed in instead. The following is an example of an ACL definition in YAML:

```yaml
---
- resources:
  - method: ALL
    path: /foo/bar/.*
  allow_x509_subject:
    ou: ponycopter
  allow_claims:
    groups: ["example"]
- resources:
  - method: ALL
    path: /_admin/?.*
  allow_claims:
    groups: ["admins"]
- resources:
  - method: GET
    path: /internal/frobnobs/.*
  allow_x509_subject:
    ou: frobnobber
- resources:
  - method: GET
    path: /
  allow_all: true
```

An ACL consists of a list of guard expressions, each of which contains a list of resources and a set of [[matchers]] which can authorize access to those resources. Access will be authorized if *any* of the matchers for a given resource are a match (i.e. matchers have "or"-like behavior, not "and"-like behavior). Requiring more than one credential to access a resource is not supported directly, but can be accomplished by having credential-extracting middleware check for credentials from previous middleware before adding new credentials to the Rack environment.

Resources are defined by the following constraints:

* **method**: The requested HTTP method, or `"ALL"` to allow any method
* **path**: A regular expression to match the path. `\A` and `\z` are added by default to the beginning and end of the regex to ensure the entire path and not a substring is matched.
* **host** (optional): a regular expression to match the `Host:` header passed by the client. Useful if your app services traffic for more than one hostname and you'd like to restrict ACLs by host.

The following [[matchers]] are built-in and always available:

* **allow_all**: (options: `true` or `false`) always allow requests to the
  given resources (so long as `true` is passed as the option)

Rails::Auth also ships with [[matchers]] for [[X.509]] certificates.