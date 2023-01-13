require 'yaml'
require "active_support/core_ext/integer/time"
Rails.application.configure do
  deliver_method = ENV.fetch('MAIL_DELIVERY_METHOD') { 'smtp' }.to_sym

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.assets.js_compressor = :terser
  config.assets.compile = true
  config.assets.digest = true
  config.force_ssl = false
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_record.dump_schema_after_migration = false

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.active_storage.service = :local

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  config.action_mailer.perform_caching = false

  cache_ssl = (ENV.fetch('CACHE_SSL') { 'false' }) == 'true'
  cache_namespace = "#{ENV.fetch('CLIENT')}-#{Rails.env}-cas"
  config.cache_store = :redis_cache_store, Rails.application.config_for(:cache_store).merge(expires_in: 8.hours, ssl: cache_ssl, namespace: cache_namespace)
  config.sandbox_email_mode = false
  config.action_mailer.delivery_method = deliver_method
  config.action_mailer.default_url_options = { host: ENV['HOSTNAME'], protocol: :https}
  if deliver_method == :smtp
    config.action_mailer.smtp_settings = {
      address: ENV['SMTP_SERVER'],
      port: 587,
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      authentication: :login,
      enable_starttls_auto: true,
    }
  end
end
