Rails::Auth includes two different middlewares for rendering error responses: one for debugging, and one intended for production environments which renders a static 403 page (or corresponding JSON response).

## Debug Page

The `Rails::Auth::ErrorPage::DebugMiddleware` provides a rich inspector for why access was denied:

![Debug Page](https://github.com/square/rails-auth/blob/master/images/debug_error_page.png?raw=true)

This page is enabled automatically in the development environment for Rails apps. It can also be enabled in production by passing the `error_page: :debug` option to `Rails::Auth::ConfigBuilder.production`. See [[Rails Usage]] for more information.

## Static Page

The `Rails::Auth::ErrorPage::Middleware` renders a static HTML page and/or JSON response in the event of an authorization failure.

This middleware is used by default in the production environment, and defaults to rendering `public/403.html`. The location of the page can be overridden using the `error_page:` option and passing a `Pathname` or `String` to the file's location. ERB is not presently supported. See [[Rails Usage]] for more information.
