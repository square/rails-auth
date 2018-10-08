source "https://rubygems.org"

group :development do
  gem "guard-rspec"
end

group :development, :test do
  # Workaround for: https://github.com/bundler/bundler/pull/4650
  gem "rack", "~> 1.x"
  gem "activesupport", "~> 4"

  gem "rake"
  gem "rspec"
  gem "rubocop", "0.49.0"
  gem "coveralls", require: false
  gem "certificate_authority", require: false
end

gemspec
