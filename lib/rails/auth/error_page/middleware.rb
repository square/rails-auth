module Rails
  module Auth
    module ErrorPage
      # Render an error page in the event Rails::Auth::NotAuthorizedError is raised
      class Middleware
        def initialize(app, page_body: nil)
          raise TypeError, "page_body must be a String" unless page_body.is_a?(String)

          @app       = app
          @page_body = page_body.freeze
        end

        def call(env)
          @app.call(env)
        rescue Rails::Auth::NotAuthorizedError
          [403, { "Content-Type" => "text/html" }, [@page_body]]
        end
      end
    end
  end
end
