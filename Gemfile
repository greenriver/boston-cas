# A sample Gemfile
source 'https://rubygems.org'

gem 'activerecord', '>= 6.1.7' # >= 6.0.5.1 due to CVE-2022-32224
gem 'activerecord-import'
gem 'pg', '~> 1.1.0'
gem 'rails', '~>6.1.7'
gem 'rails-html-sanitizer', '>= 1.4.4' # >= 1.4.4 due to CVE-2022-23519
gem 'loofah', '>= 2.19.1' # >= 2.19.1 due to GHSA-228g-948r-83gx
gem 'tzinfo', '>= 1.2.10' # CVE-2022-31163

gem 'bcrypt'
gem 'bootsnap'
gem 'composite_primary_keys', '~> 13.0'
gem 'csv', '>= 1.0.2' # support for bom|utf-8 in ruby 2.5
gem 'order_as_specified'
gem 'with_advisory_lock'
gem 'nokogiri', '>= 1.13.10' # >= 1.13.10 due to GHSA-qv4q-mr5r-qprj

gem 'autoprefixer-rails'
gem 'haml-rails'
gem 'babel-transpiler'
gem 'bootstrap', '~> 4.3.1' # updating this to 4.5.3 causes a weird missing variable bug
gem 'coffee-rails'
gem 'execjs'
gem 'jquery-rails'

gem 'validates_email_format_of'

gem 'font-awesome-sass'
gem 'simple_form'
gem 'virtus'

gem 'kaminari'
gem 'pagy'
gem 'ransack'
gem 'responders'
gem 'memoist', require: false

# File processing
gem 'carrierwave'
gem 'carrierwave-i18n'
gem 'mini_magick'
gem 'ruby-filemagic'

# AWS SDK is needed for deployment and within the application
gem 'aws-sdk-rails'
gem 'aws-sdk-autoscaling', '~> 1'
gem 'aws-sdk-cloudwatchevents', '~> 1'
gem 'aws-sdk-ecs', '~> 1'
gem 'aws-sdk-ec2', '~> 1'
gem 'aws-sdk-elasticloadbalancingv2', '~> 1'
gem 'aws-sdk-glacier', '~> 1'
gem 'aws-sdk-rds', '~> 1'
gem 'aws-sdk-s3', '~> 1'
gem 'aws-sdk-secretsmanager', '~> 1'
gem 'aws-sdk-ses', '~> 1'
gem 'aws-sdk-iam', '~> 1'
gem 'aws-sdk-ecr', '~> 1'
gem 'aws-sdk-sns', require: false
gem "aws-sdk-ssm", "~> 1"
gem 'aws-sdk-cloudwatch', require: false
gem 'aws-sdk-cloudwatchlogs', require: false
gem 'json'
gem 'amazing_print'

gem 'puma', '>= 5.6.2'
gem 'redis'
gem 'redis-actionpack'

gem 'activerecord-session_store'
gem 'lograge'
gem 'paper_trail'
gem 'paranoia', '~> 2.0'
gem 'validate_url'
gem 'StreetAddress', require: false
gem 'marginalia'
gem 'active_record_distinct_on'

gem 'devise', '~> 4'
gem 'devise_invitable'
gem 'devise-pwned_password'
gem 'devise-security'
gem 'html2haml'
gem 'pretender'
gem 'redcarpet'

gem 'authtrail' # for logging login attempts
gem 'maxminddb' # for local geocoding of login attempts

gem 'attribute_normalizer'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.42'
gem 'fuzzy_match'
gem 'handlebars_assets'
gem 'momentjs-rails', '>= 2.9.0'

gem 'delayed_job_active_record'
gem 'terser'

gem 'whenever', require: false

# Faker queries translations db in development to look for user overrides of fake data
# There is no way to disable this
gem 'faker'

gem 'slack-notifier'

gem 'daemons'
gem 'dotenv-rails'

gem 'auto-session-timeout'

# Translations
gem 'fast_gettext', require: false
gem 'gettext', '>=3.0.2', require: false
gem 'gettext_i18n_rails', require: false
gem 'grosser-pomo'
gem 'ruby_parser', require: false

# gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
# gem 'axlsx_rails'
# gem 'spreadsheet', require: false
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'xlsxtream', require: false
# NOTE: maybe https://github.com/weshatheleopard/rubyXL
gem 'roo'

gem 'browser'

group :development do
  # gem 'spring'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'

  gem 'rack-mini-profiler', require: false
  gem 'test-unit', '~> 3.0', require: false

  gem 'letter_opener'
  gem 'rails-erd'
  gem 'ruby-prof'
  gem 'web-console'
  # gem 'rb-readline'
  gem 'active_record_query_trace'
end

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'factory_bot_rails'
  gem 'foreman'
  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 4.0.0.beta3'
  gem 'timecop'

  gem 'overcommit'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-faker', require: false
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'minitest-reporters'
  gem 'rails-controller-testing'
  gem 'rspec-mocks'
  gem 'shoulda'
end

gem 'ajax_modal_rails', '~> 1.0'

gem "sentry-rails", "~> 5.5"
