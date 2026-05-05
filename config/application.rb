# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# The env var is the same as config.active_support.disable_to_s_conversion = true but impacts driver initializers that load before this app config block
#   * Note, we still use the deprecated behavior for date/time. It's preserved in config/initializers/legacy_rails_conversions.rb
ENV['RAILS_DISABLE_DEPRECATED_TO_S_CONVERSION'] = 'true'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BostonCa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Add autoload paths to load path (Rails 7.1 default)
    config.add_autoload_paths_to_load_path = false

    # Enable raising on invalid cache expiration times
    config.active_support.raise_on_invalid_cache_expiration_time = true

    # Use SQLCommenter format for query log tags
    config.active_record.query_log_tags_format = :sqlcommenter

    # Enable precompilation of filter parameters for better performance
    config.precompile_filter_parameters = true

    # Enable raising on assignment to attr_readonly attributes
    config.active_record.raise_on_assign_to_attr_readonly = true

    # Enable validating only parent-related columns for presence
    config.active_record.belongs_to_required_validates_foreign_key = false

    ###
    # Enable before_committed! callbacks on all enrolled records in a transaction.
    # The previous behavior was to only run the callbacks on the first copy of a record
    # if there were multiple copies of the same record enrolled in the transaction.
    #++
    config.active_record.before_committed_on_all_records = true

    # Keep YAML as default column serializer (you have this set in your 7.1 file)
    config.active_record.default_column_serializer = YAML

    # Run after_commit callbacks in order defined
    config.active_record.run_after_transaction_callbacks_in_order_defined = true

    # Generate secure tokens on initialize
    config.active_record.generate_secure_token_on = :initialize

    # Use HTML5 sanitizers when supported
    config.action_view.sanitizer_vendor = Rails::HTML::Sanitizer.best_supported_vendor
    config.action_text.sanitizer_vendor = Rails::HTML::Sanitizer.best_supported_vendor

    # Use HTML5 parser for DOM testing
    config.dom_testing_default_html_version = :html5

    # Set log file size for local environments
    config.log_file_size = 100 * 1024 * 1024 if Rails.env.local?

    # Continue to use config/secrets.yml. This is deprecated in rails > 7.0 but we don't want to move to
    # encrypted credentials, it's not appropriate for an open-source project
    if File.exist?(Rails.root.join('config', 'secrets.yml'))
      config.secrets = config_for(:secrets) # loads from config/secrets.yml
      config.secret_key_base = config.secrets[:secret_key_base]

      def secrets
        config.secrets
      end
    end

    # FIXME Suppress the Rails 5 belongs_to requirement
    config.active_record.belongs_to_required_by_default = false

    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    config.active_record.use_yaml_unsafe_load = true

    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    config.time_zone = ENV['TIMEZONE']
    config.action_controller.include_all_helpers = false
    config.active_record.schema_format = :sql
    config.active_job.queue_adapter = :delayed_job

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework :rspec
    end

    require_relative('setup_logging')
    setup_logging = SetupLogging.new(config)
    setup_logging.run!

    # By default, all emails will only go to DND staff
    config.sandbox_email_mode = true

    # force all requests over ssl by default
    config.force_ssl = true

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ['assets', 'tasks', 'util'])

    # Configure ActiveRecord Query Logs (replaces marginalia gem)
    # This provides SQL query tagging for debugging in development
    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags = [:application, :controller, :action, :line]
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_storage.draw_routes = true
  end
end
