# A sample Gemfile
source "https://rubygems.org"

gem "pg"
gem 'activerecord-import'
gem "rails"
gem 'bcrypt'

gem "haml-rails"
gem "sass-rails"
gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem "jquery-rails"
gem 'coffee-rails'
# TODO move to assets group
gem 'execjs'
gem 'sprockets-es6'

gem 'letsencrypt_plugin'

gem 'validates_email_format_of'

gem "simple_form"
gem 'virtus'
gem 'font-awesome-sass'

gem 'kaminari'
gem 'ransack'

# No attachment to unicor here-- probably want to go with passenger or puma
gem 'unicorn-rails'

gem "lograge"
gem 'activerecord-session_store'
gem 'paranoia', '~> 2.0'
gem 'paper_trail'

gem 'html2haml'
gem 'devise', '~> 3.5'
gem 'devise_invitable'
gem 'handlebars_assets'
gem 'select2-rails'
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

group :development do
  gem 'spring'
  gem 'brakeman', require: false
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano3-delayed-job', '~> 1.0'
  gem 'puma'

  # gem 'rack-mini-profiler'
  gem 'test-unit', '~> 3.0', require: false

  gem 'rails-erd'
  gem 'web-console'
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'ruby-prof'
  gem 'rb-readline'
end

group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'foreman'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec', require: false
end

group :test do
  gem "capybara"
  gem "launchy"
  gem 'minitest-reporters'
  gem 'rspec-mocks'
end
