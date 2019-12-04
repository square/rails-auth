# frozen_string_literal: true

require "active_support/hash_with_indifferent_access"

# rubocop:disable Naming/MemoizedInstanceVariableName
module Rails
  module Auth
    # Convenience methods designed to be included in an ActionController::Base subclass
    # Recommended use: include in ApplicationController
    module ControllerMethods
      # Obtain credentials for the current request
      #
      # @return [HashWithIndifferentAccess] credentials extracted from the environment
      #
      def credentials
        @_rails_auth_credentials ||= begin
          creds = Rails::Auth.credentials(request.env)
          HashWithIndifferentAccess.new(creds).freeze
        end
      end
    end
  end
end
# rubocop:enable Naming/MemoizedInstanceVariableName
