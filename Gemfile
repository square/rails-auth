# frozen_string_literal: true

source "https://rubygems.org"

group :development do
  gem "guard-rspec"
end

group :development, :test do
  gem "activesupport", "~> 4"
  gem "certificate_authority", require: false
  gem "coveralls", require: false
  # Workaround for: https://github.com/bundler/bundler/pull/4650
  gem "rack", "~> 1.x"
  gem "rake"
  gem "rspec"
  gem "rubocop", "0.77.0"
end

gemspec
