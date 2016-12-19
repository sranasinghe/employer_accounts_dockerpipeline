require 'simplecov'
SimpleCov.minimum_coverage 95
SimpleCov.start 'rails' do
  add_filter '/docker/'
end

require File.expand_path('../../config/environment', __FILE__)
require_relative '../test/support/env_vars'
require_relative '../test/support/fixture_loader'
require_relative '../test/test_helpers/test_logger'
require 'rails/test_help'
require 'minitest/rails'
require 'minitest/rails/capybara'
require 'minitest/autorun'
require 'minitest/focus'
require 'minitest/red_green'
require 'mocha/mini_test'
require 'webmock/minitest'
#
require 'database_cleaner'
require 'fabrication'

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  set_fixture_class doorkeeper_applications: Doorkeeper::Application
  fixtures :all

  # Add more helper methods to be used by all tests here...
  #
end

Dir[File.expand_path('../support/*.rb', __FILE__)].each do |f|
  require f
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app/**/*'))

DatabaseCleaner.strategy = :transaction

class Minitest::Test
  def setup
    DatabaseCleaner.start
  end

  def teardown
    ActionMailer::Base.deliveries = []
    WebMock.reset!
    DatabaseCleaner.clean
  end

  class << self
    alias context describe
  end
end

def private_key
  pk_string = File.open(Rails.root.join('test', 'private_keys', 'test_private_key.pem'), 'r').read
  OpenSSL::PKey::RSA.new(pk_string)
end

def create_headers(private_key, request_body)
  digest = OpenSSL::Digest::SHA256.new
  signature = private_key.sign(digest, request_body)
  { 'CONTENT_TYPE' => 'application/json', 'HTTP_WM_SIGNATURE' => "test:#{Base64.strict_encode64(signature).strip}" }
end
