# A sample Gemfile
source "https://rubygems.org"

gem 'tiny_tds'
gem 'activerecord-sqlserver-adapter'
gem "pg"
gem 'activerecord-import'
gem "rails"
gem 'bcrypt'
gem 'spring'
gem "haml-rails"
gem "sass-rails"
gem 'autoprefixer-rails'
gem 'bootstrap-sass'
gem "jquery-rails"
gem 'coffee-rails'
# TODO move to assets group
gem 'execjs'
gem 'sprockets-es6'

gem 'validates_email_format_of'

gem "simple_form"
gem 'font-awesome-sass'

gem 'kaminari'

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

gem 'delayed_job_active_record'
gem 'uglifier'

gem 'whenever', :require => false
gem 'faker'

group :development do
  gem 'brakeman', require: false
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  # gem 'capistrano-passenger'
  gem 'capistrano-rails'

  # gem 'rack-mini-profiler'
  gem 'test-unit', '~> 3.0', require: false

  gem 'rails-erd'
  gem 'web-console'
  gem 'letter_opener'
  gem 'quiet_assets'
  gem 'ruby-prof'
end

group :development, :test do
  gem 'pry-rails'
  gem 'foreman'
end

group :test do
  gem "capybara"
  gem "launchy"
  gem 'minitest-reporters'
  gem 'rspec-mocks'
end
