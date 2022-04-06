Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  slack_config = Rails.application.config_for(:exception_notifier)[:slack]
  if slack_config.present?
    config.middleware.use(ExceptionNotification::Rack,
      :slack => {
        :webhook_url => slack_config[:webhook_url],
        :channel => slack_config[:channel],
        :additional_parameters => {
          :mrkdwn => true,
          :icon_url => slack_config[:icon_url]
        }
      }
    )
  end

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  config.assets.js_compressor = Uglifier.new(harmony: true)
  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  if ENV['SMTP_SERVER']
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.default_url_options = { host: ENV['FQDN'], protocol: 'http'}
    smtp_port = ENV.fetch('SMTP_PORT'){ 587 }
    config.action_mailer.perform_deliveries = true
    if ENV['SMTP_USERNAME'] && ENV['SMTP_PASSWORD']
      config.action_mailer.smtp_settings = {
        address: ENV['SMTP_SERVER'],
        port: smtp_port,
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD'],
        authentication: :login,
        enable_starttls_auto: true,
      }
    else
      config.action_mailer.smtp_settings = {
        address: ENV['SMTP_SERVER'],
        port: smtp_port,
      }
    end
  else
    # Don't care if the mailer can't send.
    config.action_mailer.raise_delivery_errors = false

    config.action_mailer.delivery_method = ENV.fetch("DEV_MAILER") { :letter_opener }.to_sym
  end
  config.action_mailer.perform_caching = false

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  if ENV['ENABLE_EVENT_FS_CHECKER'] == '1'
    config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  end

  # Devise requires a default URL
  config.action_mailer.default_url_options = { host: ENV['HOSTNAME'], port: ENV['PORT'], protocol: :http }

  # don't need email sandbox with letter opener
  config.sandbox_email_mode = true

  config.force_ssl = false
  config.cache_store = :redis_cache_store, Rails.application.config_for(:cache_store).merge(expires_in: 8.hours)

  # Web console from outside of docker
  config.web_console.whitelisted_ips = ['172.16.0.0/12', '192.168.0.0/16', '10.0.0.0/8']

  # do gzip compressing in dev mode to simulate nginx config in production
  config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

  # Disable hostname checking for puma-dev
  Rails.application.configure do
    config.hosts.clear
  end


  I18n.config.available_locales = :en

  # for testing purposes
  Rails.application.config.middleware.use ExceptionNotification::Rack,
  email: {
    exception_recipients: %w{test-noreply@example.com}
  }
end
