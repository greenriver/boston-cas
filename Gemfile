# A sample Gemfile
source 'https://rubygems.org'

gem 'activerecord-import'
gem 'rack'
gem 'pg', '~> 1.1'
gem 'rails', '~> 7.2.2.2'
gem 'sprockets-rails'
gem 'rails-html-sanitizer'
gem 'loofah'
gem 'tzinfo', '>= 1.2.10' # CVE-2022-31163

# No longer default gems
gem 'irb'
gem 'reline'
gem 'benchmark'
gem 'rdoc'
gem 'mutex_m'
gem 'drb'

gem 'bcrypt'
gem 'bootsnap'
gem 'csv'
gem 'order_as_specified'
gem 'with_advisory_lock'
gem 'nokogiri'

gem 'autoprefixer-rails'
gem 'haml-rails'
gem 'babel-transpiler'
gem 'bootstrap', '~> 4.3.1' # updating this to 4.5.3 causes a weird missing variable bug
gem 'coffee-rails'
gem 'execjs'
gem 'jquery-rails'

# Temporary fix until we know why it isn't installing
gem 'mini_portile2'

gem 'validates_email_format_of'

gem 'font-awesome-sass'
gem 'simple_form'
gem 'virtus'

gem 'kaminari'
gem 'pagy', '~> 8.2'
gem 'responders'
gem 'memery', require: false
gem 'todo_or_die'

# File processing
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
gem 'aws-sdk-ssm', '~> 1'
gem 'aws-sdk-cloudwatch', require: false
gem 'aws-sdk-cloudwatchlogs', require: false
gem 'json'
gem 'amazing_print'

gem 'puma', '~> 6'
gem 'redis'

gem 'activerecord-session_store'
gem 'lograge'
gem 'logstop'
gem 'paper_trail' # , '~> 15' # 16 breaks models with inherited has_paper_trail, need to update significant code
gem 'paranoia'
gem 'validate_url'
gem 'StreetAddress', require: false
gem 'marginalia'
gem 'active_record_distinct_on'

gem 'devise', '~> 4'
gem 'devise_invitable', '>= 2.0.9'
gem 'devise-pwned_password'
gem 'devise-security'
gem 'html2haml'
gem 'pretender'
gem 'redcarpet'

gem 'authtrail' # for logging login attempts
gem 'maxminddb' # for local geocoding of login attempts
gem 'geocoder'

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

gem 'ruby_parser', require: false

gem 'caxlsx'
gem 'caxlsx_rails'
gem 'xlsxtream', require: false
# NOTE: maybe https://github.com/weshatheleopard/rubyXL
gem 'roo'

gem 'browser'
gem 'net-http'
gem 'ajax_modal_rails', '~> 1.0'

gem 'sentry-rails', '~> 5.5'
gem 'warning'

# Metrics
gem 'yabeda-rails'
gem 'yabeda-prometheus'
gem 'yabeda-puma-plugin'
gem 'roda'

# Once 0.17 is released we should be able to unpin this
# https://github.com/k8s-ruby/k8s-ruby/pull/57
gem 'k8s-ruby', github: 'k8s-ruby/k8s-ruby', branch: 'master'

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'

  gem 'rack-mini-profiler', require: false

  # gem 'letter_opener'
  # gem 'rails-erd'
  gem 'ruby-prof'
  gem 'web-console'
  gem 'active_record_query_trace'
end

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  # gem 'foreman'
  # gem 'guard-rspec', require: false
  # gem 'listen'
  gem 'pry-byebug'
  gem 'pry-rails'

  gem 'overcommit'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-faker', require: false
  gem 'deprecation_toolkit', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'minitest-reporters'
  gem 'rails-controller-testing'
  gem 'rspec-mocks'
  gem 'shoulda-matchers'
end
