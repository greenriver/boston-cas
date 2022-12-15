require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BostonCa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # FIXME Suppress the Rails 5 belongs_to requirement
    Rails.application.config.active_record.belongs_to_required_by_default = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017
    config.active_record.use_yaml_unsafe_load = true

    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = ENV['TIMEZONE']

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_controller.include_all_helpers = false

    config.active_record.schema_format = :ruby

    config.active_job.queue_adapter = :delayed_job

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework :rspec
    end

    require_relative("setup_logging")
    setup_logging = SetupLogging.new(config)
    setup_logging.run!

    # By default, all emails will only go to DND staff
    config.sandbox_email_mode = true

    # force all requests over ssl by default
    config.force_ssl = true


    # additional library paths
    config.autoload_paths << Rails.root.join('lib', 'util')
  end
end
