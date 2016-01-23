module Rails
  module Auth
    # Unauthorized!
    NotAuthorizedError = Class.new(StandardError)

    # Error parsing e.g. an ACL
    ParseError = Class.new(StandardError)
  end
end
