module Rails
  module Auth
    class ACL
      # Built-in predicate matchers
      module Matchers
        # Allows unauthenticated clients to access to a given resource
        class AllowAll
          def initialize(enabled)
            fail ArgumentError, "enabled must be true/false" unless [true, false].include?(enabled)
            @enabled = enabled
          end

          def match(_env)
            @enabled
          end
        end

        # Make `allow_all` available by default as an ACL matcher
        ACL::DEFAULT_MATCHERS[:allow_all] = AllowAll
      end
    end
  end
end
