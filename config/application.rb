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
    config.load_defaults 7.0

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

    # Set frozen_string_literal to true for all files in the app
    config.frozen_string_literal = true

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
    config.autoload_lib(ignore: ['assets', 'tasks'])
    config.autoload_paths << Rails.root.join('lib', 'util')
  end
end
