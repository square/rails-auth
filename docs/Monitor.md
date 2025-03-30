The `Rails::Auth::Monitor::Middleware` invokes a user-specified callback each time an AuthZ decision is made. The callback should look like this:

```ruby
my_monitor_callback = lambda do |env, success|
  [...]
end
```

The parameters are:

* **env:** the full Rack environment associated with the request
* **success:** whether or not the request was authorized

On Rails, you can pass this callback as the `monitor:` option to `Rails::Auth::ConfigBuilder.production`. See [[Rails Usage]] for more information.

On Rack, you will have to instantiate the middleware yourself. See [[Rack Usage]] for more information.

These callbacks are useful for logging authorization decisions and/or reporting authorization failures to e.g. a central monitoring/alerting system.