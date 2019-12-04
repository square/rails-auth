# frozen_string_literal: true

module Rails
  module Auth
    # Rails constraint to make sure the ACLs have been installed
    class InstalledConstraint
      def initialize(config = Rails.application)
        @config = config
      end

      def matches?(_request)
        @config.middleware.include?(Rails::Auth::ACL::Middleware)
      end
    end
  end
end
