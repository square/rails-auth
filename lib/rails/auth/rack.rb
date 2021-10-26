# frozen_string_literal: true

# Core library components that work with any Rack application
require "rack"
require "openssl"

require "rails/auth/version"

require "rails/auth/env"
require "rails/auth/exceptions"
require "rails/auth/helpers"

require "rails/auth/acl"
require "rails/auth/acl/middleware"
require "rails/auth/acl/resource"

require "rails/auth/credentials"
require "rails/auth/credentials/injector_middleware"

require "rails/auth/error_page/middleware"
require "rails/auth/error_page/debug_middleware"

require "rails/auth/monitor/middleware"

require "rails/auth/x509/certificate"
require "rails/auth/x509/filter/pem"
require "rails/auth/x509/filter/pem_urlencoded"
require "rails/auth/x509/filter/java" if defined?(JRUBY_VERSION)
require "rails/auth/x509/matcher"
require "rails/auth/x509/middleware"
require "rails/auth/x509/subject_alt_name_extension"
