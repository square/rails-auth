# frozen_string_literal: true

require "erb"
require "cgi"

module Rails
  module Auth
    module ErrorPage
      # Render a descriptive access denied page with debugging information about why the given
      # request was not authorized. Useful for debugging, but leaks information about your ACL
      # to a potential attacker. Make sure you're ok with that information being public.
      class DebugMiddleware
        # Configure CSP to disable JavaScript, but allow inline CSS
        # This is just in case someone pulls off reflective XSS, but hopefully all values are
        # properly escaped on the page so that won't happen.
        RESPONSE_HEADERS = {
          "Content-Type" => "text/html",
          "Content-Security-Policy" =>
          "default-src 'self'; " \
          "script-src 'none'; " \
          "style-src 'unsafe-inline'"
        }.freeze

        def initialize(app, acl: nil)
          raise ArgumentError, "ACL must be a Rails::Auth::ACL" unless acl.is_a?(Rails::Auth::ACL)

          @app = app
          @acl = acl
          @erb = ERB.new(File.read(File.expand_path("debug_page.html.erb", __dir__))).freeze
        end

        def call(env)
          @app.call(env)
        rescue Rails::Auth::NotAuthorizedError
          [403, RESPONSE_HEADERS.dup, [error_page(env)]]
        end

        def error_page(env)
          credentials = Rails::Auth.credentials(env)
          resources   = @acl.matching_resources(env)

          @erb.result(binding)
        end

        def h(text)
          CGI.escapeHTML(text || "")
        end

        def format_attributes(value)
          value.respond_to?(:attributes) ? value.attributes.inspect : value.inspect
        end

        def format_path(path)
          path.source.sub(/\A\\A/, "").sub(/\\z\z/, "")
        end
      end
    end
  end
end
