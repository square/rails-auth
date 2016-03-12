module Rails
  module Auth
    class ACL
      # Built-in predicate matchers
      module Matchers
        # Allows unauthenticated clients to access to a given resource
        class AllowAll
          def initialize(enabled)
            raise ArgumentError, "enabled must be true/false" unless [true, false].include?(enabled)
            @enabled = enabled
          end

          def match(_env)
            @enabled
          end
        end
      end
    end
  end
end
