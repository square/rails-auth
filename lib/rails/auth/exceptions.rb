# frozen_string_literal: true

module Rails
  module Auth
    # Base class of all Rails::Auth errors
    Error = Class.new(StandardError)

    # Unauthorized!
    NotAuthorizedError = Class.new(Error)

    # Error parsing e.g. an ACL
    ParseError = Class.new(Error)

    # Internal errors involving authorizing things that are already authorized
    AlreadyAuthorizedError = Class.new(Error)
  end
end
