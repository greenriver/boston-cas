# A sample Gemfile
source "https://rubygems.org"

gem "pg"
gem 'activerecord-import'
gem 'composite_primary_keys', '~> 8.0'
gem "rails"
gem 'bcrypt'
gem 'with_advisory_lock'
gem 'csv', '>= 1.0.2' # support for bom|utf-8 in ruby 2.5

gem "haml-rails"
gem "sass-rails"
gem 'autoprefixer-rails'
gem 'bootstrap', '~> 4.3.1'
gem "jquery-rails"
gem 'coffee-rails'
# TODO move to assets group
gem 'execjs'
gem 'sprockets-es6'

gem 'letsencrypt_plugin'

gem 'validates_email_format_of'

gem "simple_form"
gem 'virtus'
gem 'font-awesome-sass', '~> 5.0.9'

gem 'responders'
gem 'kaminari'
gem 'ransack'

# File processing
gem 'carrierwave'
gem 'carrierwave-i18n'
gem 'ruby-filemagic'
gem 'mini_magick'

# No attachment to unicorn here-- probably want to go with passenger or puma
gem 'unicorn-rails'
gem 'redis-rails'

gem "lograge"
gem 'activerecord-session_store'
gem 'paranoia', '~> 2.0'
gem 'paper_trail'

gem 'html2haml'
gem 'devise', '~> 4'
gem 'devise_invitable'
gem 'devise-pwned_password'
gem 'pretender'

gem 'authtrail' # for logging login attempts
gem 'maxminddb' # for local geocoding of login attempts

gem 'handlebars_assets'
gem 'select2-rails', git: 'https://github.com/greenriver/select2-rails.git'
gem 'fuzzy_match'
gem 'attribute_normalizer'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.42'

gem 'delayed_job_active_record'
gem 'uglifier'

gem 'whenever', :require => false

# Faker queries translations db in development to look for user overrides of fake data
# There is no way to disable this
gem 'faker'

gem 'slack-notifier'
gem 'exception_notification'

gem 'dotenv-rails'
gem 'daemons'

gem 'auto-session-timeout'

#Translations
gem 'gettext_i18n_rails'
gem 'fast_gettext'
gem 'gettext', '>=3.0.2', require: false
gem 'ruby_parser', require: false
gem 'grosser-pomo'

# gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
# gem 'axlsx_rails'
# gem 'spreadsheet', require: false
gem 'xlsxtream', require: false
# NOTE: maybe https://github.com/weshatheleopard/rubyXL
gem 'roo'

group :development do
  # gem 'spring'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'puma'

  gem 'rack-mini-profiler', require: false
  gem 'test-unit', '~> 3.0', require: false

  gem 'rails-erd'
  gem 'web-console'
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'ruby-prof'
  # gem 'rb-readline'
  gem 'active_record_query_trace'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'foreman'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec', require: false
  gem 'timecop'
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
end

group :test do
  gem "capybara"
  gem "launchy"
  gem 'minitest-reporters'
  gem 'rspec-mocks'
  gem 'shoulda'
end
