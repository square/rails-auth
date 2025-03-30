## Intro

* [[Design Overview]]: an overview of Rails::Auth's middleware-based design
* [[Comparison With Other Libraries]]: How Rails::Auth compares to other Rails/Rack auth libraries/frameworks

## Usage

* [[Rails Usage]]: how to add Rails::Auth to a Rails app
* [[Rack Usage]]: how to use Rails::Auth's middleware outside of a Rails app
* [[Access Control Lists]]: how to define policy for what actions are allowed
* [[Matchers]]: how to make access control decisions based on credentials
* [[X.509]]: how to authorize requests using X.509 client certificates
* [[Error Handling]]: show a rich debugger or static 403 page on authorization errors
* [[Monitor]]: invokes a user-specified callback each time an AuthZ decision is made
* [[RSpec Support]]: use RSpec to write integration tests for Rails::Auth features and specs for ACLs