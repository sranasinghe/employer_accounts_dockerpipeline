source 'https://rubygems.org'

gem 'airbrake', '< 4.0.0'
gem 'bcrypt', '~> 3.1.7'
gem 'doorkeeper', '~> 3.1.0'
gem 'doorkeeper-jwt', '~> 0.1.4'
gem 'faraday', '~> 0.9.1'
gem 'faraday_middleware', '~> 0.10.0'
gem 'grape'
gem 'grape-entity', '=0.5.0' # grape-entity broke a ton of stuff in 0.5.1.  Check back on progress
gem 'grape-swagger-entity'
gem 'grape-swagger', git: 'https://github.com/ruby-grape/grape-swagger.git'
gem 'grape-swagger-rails'
gem 'haml'
gem 'hashie'
gem 'hashie-forbidden_attributes', git: 'https://github.com/Maxim-Filimonov/hashie-forbidden_attributes'
gem 'pg'
gem 'puma', '~> 2.13.4'
gem 'rails', '~> 4.2'
gem 'responders'
gem 'schema_plus_views', '~> 0.3.0'
gem 'sucker_punch'
gem 'virtus'
gem 'newrelic_rpm'
gem 'grape_on_rails_routes'

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'minitest-flyordie', require: false
  gem 'minitest-focus'
  gem 'minitest-rails'
  gem 'minitest-rails-capybara'
  gem 'minitest-red_green'
  gem 'mocha'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'webmock'
end
