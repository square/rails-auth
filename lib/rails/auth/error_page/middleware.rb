# frozen_string_literal: true

module Rails
  module Auth
    module ErrorPage
      # Render an error page in the event Rails::Auth::NotAuthorizedError is raised
      class Middleware
        def initialize(app, page_body: nil, json_body: { message: "Access denied" })
          raise TypeError, "page_body must be a String" unless page_body.is_a?(String)

          @app       = app
          @page_body = page_body.freeze
          @json_body = json_body.to_json
        end

        def call(env)
          @app.call(env)
        rescue Rails::Auth::NotAuthorizedError
          access_denied(env)
        end

        private

        def access_denied(env)
          case response_format(env)
          when :json
            [403, { "X-Powered-By" => "rails-auth", "Content-Type" => "application/json" }, [@json_body]]
          else
            [403, { "X-Powered-By" => "rails-auth", "Content-Type" => "text/html" }, [@page_body]]
          end
        end

        def response_format(env)
          accept_format = env["HTTP_ACCEPT"]
          return :json if accept_format && accept_format.downcase.start_with?("application/json")
          return :json if env["PATH_INFO"] && env["PATH_INFO"].end_with?(".json")

          nil
        end
      end
    end
  end
end
