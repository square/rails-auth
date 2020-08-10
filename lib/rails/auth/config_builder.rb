# frozen_string_literal: true

module Rails
  module Auth
    # Configures Rails::Auth middleware for use in a Rails application
    module ConfigBuilder
      extend self

      # Application-level configuration (i.e. config/application.rb)
      def application(config, acl_file: Rails.root.join("config/acl.yml"), matchers: {})
        config.x.rails_auth.acl = Rails::Auth::ACL.from_yaml(
          File.read(acl_file.to_s),
          matchers: matchers
        )

        config.middleware.use Rails::Auth::ACL::Middleware, acl: config.x.rails_auth.acl
      end

      # Development configuration (i.e. config/environments/development.rb)
      def development(config, development_credentials: {}, error_page: :debug)
        error_page_middleware(config, error_page)
        credential_injector_middleware(config, development_credentials) unless development_credentials.empty?
      end

      # Test configuration (i.e. config/environments/test.rb)
      def test(config)
        # Simulated credentials to be injected with InjectorMiddleware
        credential_injector_middleware(config, config.x.rails_auth.test_credentials ||= {})
      end

      def production(
        config,
        cert_filters: nil,
        error_page: Rails.root.join("public/403.html"),
        monitor: nil
      )
        error_page_middleware(config, error_page)

        if cert_filters
          config.middleware.insert_before Rails::Auth::ACL::Middleware,
                                          Rails::Auth::X509::Middleware,
                                          cert_filters: cert_filters,
                                          logger:       Rails.logger
        end

        return unless monitor

        config.middleware.insert_before Rails::Auth::ACL::Middleware,
                                        Rails::Auth::Monitor::Middleware,
                                        monitor
      end

      private

      # Adds error page middleware to the chain
      def error_page_middleware(config, error_page)
        case error_page
        when :debug
          config.middleware.insert_before Rails::Auth::ACL::Middleware,
                                          Rails::Auth::ErrorPage::DebugMiddleware,
                                          acl: config.x.rails_auth.acl
        when Pathname, String
          config.middleware.insert_before Rails::Auth::ACL::Middleware,
                                          Rails::Auth::ErrorPage::Middleware,
                                          page_body: Pathname(error_page).read
        when FalseClass, NilClass
          nil
        else raise TypeError, "bad error page mode: #{mode.inspect}"
        end
      end

      # Adds Rails::Auth::Credentials::InjectorMiddleware to the chain with the given credentials
      def credential_injector_middleware(config, credentials)
        config.middleware.insert_before Rails::Auth::ACL::Middleware,
                                        Rails::Auth::Credentials::InjectorMiddleware,
                                        credentials
      end
    end
  end
end
