ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require "rspec/mocks"
require 'support/smoke_test'
require 'support/user_factory'

class ActiveSupport::TestCase
  # NO FIXTURES please
  # use db/seed scripts or build content in each test
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

require 'minitest/reporters'
unless ENV["MINITEST_NOCOLOR"]
  Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new(:color => true),
    ENV,
    Minitest.backtrace_filter
end

# Make the Capybara DSL available in all integration tests
class ActionDispatch::IntegrationTest
  include Capybara::DSL
end

# Use RSpec Mocks in Minitest tests
module MinitestRSpecMocksIntegration
  include ::RSpec::Mocks::ExampleMethods

  def before_setup
    ::RSpec::Mocks.setup
    super
  end

  def after_teardown
    super
    ::RSpec::Mocks.verify
  ensure
    ::RSpec::Mocks.teardown
  end
end
Minitest::Test.send(:include, MinitestRSpecMocksIntegration)
RSpec::Mocks.configuration.verify_partial_doubles = true
