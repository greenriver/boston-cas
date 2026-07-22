###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

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
    # Load framework defaults for the current Rails version. Overrides below are
    # intentional deviations from these defaults.
    config.load_defaults 8.1

    # Keep YAML as the default column serializer. The framework default is `nil`
    # (Rails 7.1+); this is an intentional override to preserve existing
    # serialized-column behavior.
    config.active_record.default_column_serializer = YAML

    # Force the HTML5 parser for DOM testing. The framework default falls back to
    # :html4 when Nokogiri::HTML5 is unavailable; we always want :html5.
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

    # NOTE: on load_defaults 8.1, active_record.postgresql_adapter_decode_dates is
    # `true` — raw-SQL `date` columns return Date, not String. Accepted intentionally after review

    # Disable Active Storage routes
    config.active_storage.draw_routes = false
  end
end
