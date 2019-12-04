# frozen_string_literal: true

module Rails
  module Auth
    class ACL
      # Authorizes requests by matching them against the given ACL
      class Middleware
        # Create Rails::Auth::ACL::Middleware from the args you'd pass to Rails::Auth::ACL's constructor
        def self.from_acl_config(app, **args)
          new(app, acl: Rails::Auth::ACL.new(**args))
        end

        # Create a new ACL Middleware object
        #
        # @param [Object] app next app in the Rack middleware chain
        # @param [Hash]   acl Rails::Auth::ACL object to authorize the request with
        #
        # @return [Rails::Auth::ACL::Middleware] new ACL middleware instance
        def initialize(app, acl: nil)
          raise ArgumentError, "no acl given" unless acl

          @app = app
          @acl = acl
        end

        def call(env)
          unless Rails::Auth.authorized?(env)
            matcher_name = @acl.match(env)
            raise NotAuthorizedError, "unauthorized request" unless matcher_name

            Rails::Auth.set_allowed_by(env, "matcher:#{matcher_name}")
          end

          @app.call(env)
        end
      end
    end
  end
end
