source "https://rubygems.org"


# En tu Gemfile (grupo principal, no en development/test):
gem "puma", "~> 6.4"  # Versión estable
gem "thruster", require: false  # El `require: false` evita carga automática si no es necesaria
gem "rails", "~> 8.0.2"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "faker", "~> 3.5"
gem "axlsx_rails"
gem 'csv'
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
