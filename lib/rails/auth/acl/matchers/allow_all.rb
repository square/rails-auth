# frozen_string_literal: true

module Rails
  module Auth
    class ACL
      # Built-in matchers
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

          # Generates inspectable attributes for debugging
          #
          # @return [true, false] is the matcher enabled?
          def attributes
            @enabled
          end
        end
      end
    end
  end
end
