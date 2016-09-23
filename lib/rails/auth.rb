# frozen_string_literal: true

# Pull in core library components that work with any Rack application
require "rails/auth/rack"

# Rails configuration builder
require "rails/auth/config_builder"

# Rails controller method support
require "rails/auth/controller_methods"

# Rails router constraint
require "rails/auth/installed_constraint"
