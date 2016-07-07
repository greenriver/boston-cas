# Boston Coordinated Access


# Development Dependancies

* `ruby 2.3+`
* `bundler`
* `postgresql`


### Setting Up Development Environment
Just run `bin/setup` from the project directory.  It will install gems, set up databases, and import necessary seed data.

### Running Tests

To set up your test environment and databases, run `RAILS_ENV=test bin/setup` from the project directory.  Tests can be run with `bin/rake test`

# Other notes

* views are in bootstrap3 (`assets/stylesheets/_bootstrap-custom.scss`), haml, sass, simple_form, kaminari
* `brakeman` should show no new warnings with your code.
* `rack-mini-profiler` can be used to make sure pages are fast. Ideally <200ms
* helpers need to be explictly loaded in controllers `config.action_controller.include_all_helpers = false`
* `bin/rake generate controller ... ` doesn't make fixures and they are disabled in test_helper
* it also doesn't make helper or asset stubs, make them by hand if you need one. See `config/application.rb`
