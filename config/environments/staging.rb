require 'yaml'
Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = true
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true
  config.force_ssl = false
  config.log_level = :info
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
  config.sandbox_email_mode = true
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_url_options = { host: 'cas-staging.boston.gov', protocol: 'https'}
  config.action_mailer.smtp_settings = YAML.load_file('config/mail_account.yml')
end
