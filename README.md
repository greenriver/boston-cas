# Boston Coordinated Access

## Introduction
The Boston Coordinated Access system was started by the City of Boston, Dept. of Neighborhood Development to help in matching homeless individuals to housing vacancies based on need. The Coordinated Access system centralizes vacancies to permanent supportive housing units using a customisable rule-based system. Once a match is proposed by the sytem using these rules it supports web/email based workflow to work with the client, Dept. of Neighborhood Development staff, Sheleter Agencies and Housing providers to verify eligability and coordiante the housing oppertunity. See [`docs/Flow May Vouchers.pdf`](https://github.com/greenriver/boston-cas/raw/master/docs/Flow%20Map%20Vouchers.pdf) for an example.

```
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
```

A copy of the the license is available in [LICENCE.md](https://github.com/greenriver/boston-cas/blob/master/LICENSE.md)

## Application Design

The application designed around the [HUD Data Standards](https://www.hudexchange.info/programs/hmis/hmis-data-and-technical-standards/). You can find copies of some relavent documenation in the `docs` folder.

The application is written primarily in [Ruby on Rails](http://rubyonrails.org) and we use [RVM](https://rvm.io/) to select a ruby version. Other ruby version managers should work fine, as would manually installing the ruby version mentioned in the `.ruby-version`

The application uses [postgres](https://www.postgresql.org/) as a default primary data storage. Data connectors to other HMIS systems is not included in this release but simple example method using CSV files is available. In Boston's deployment we have connections using various combinations of Microsoft SQL Server, SFTP of CSV and XML, and live API connections.

We've develop locally on OSX using [homebrew](http://brew.sh/) and deploy to Ubuntu 16.04 using `apt` for dependancies.

## Screen Shots
##### A Match in Progress
![Image of a match in progress](https://github.com/greenriver/boston-cas/blob/master/docs/screenshots/match-detail.png)
##### Editing Program roles
![Image of a match in progress](https://github.com/greenriver/boston-cas/blob/master/docs/screenshots/rules-editing.png)

### Developer Prequisites

If you are unfamilar with contributing to open source projects on github you may first want to read some of the guides at:  https://guides.github.com/

There is a simple script to setup a development environment in `bin/setup`. To make it run smoothly you should have:

* A running Ruby 2.3+ environment with bundler 1.11+ installed.
* A local install of postgresql 9.4+ allowing your user to create new databases.

Once these are in-place `bin/setup` should:

* Install all ruby dependancies.
* Create initial copies of configuration files.
* Create an initial database and seed it with reference data and a randomly generated admin user.
* Add some example data that in production would come from your HMIS integration.

If all goes well you should then be able to run `bin/rails server` and open the CAS in your system at http://localhost:3000 using the email/password created during `bin/setup`. If not, read `bin/setup` to figure out what when wrong and fix it.

Hack on your version as you see fit and if you have questions or want to contibute open an issue on github.

# Developer notes

We use the following common rails gem's and conventions:

* `haml` for view templating
* `bootstrap` for base styles and layout
* `sass` for custom-css
* `simple_form` for forms
* `kaminari` for pagination
* `brakeman` for basic security scanning.
* `rack-mini-profiler` to make sure pages are fast. Ideally <200ms
* helpers need to be explictly loaded in controllers. i.e. we have `config.action_controller.include_all_helpers = false` set
* `bin/rake generate controller ... ` doesn't make fixures and they are disabled in test_helper. We dont use them and instead seed data in test or let test create their own data however they need to.
* it also doesn't make helper or asset stubs, make them by hand if you need one. See `config/application.rb` for details.
