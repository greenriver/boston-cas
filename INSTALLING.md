# Manual Deploy on Ubuntu 14.04

Make a directory for the application to live in (or set it up with its own user)

 ```
$ sudo mkdir -p /u/apps/boston-cas
$ sudo chown -R `whoami`:`whoami` /u/apps/boston-cas
$ cd /u/apps/boston-cas
 ```

### Prerequisites

1. Ensure you have `git` installed and clone the repo
 ```bash
sudo apt-get install git
git clone git@github.com:greenriver/boston-cas.git /u/apps/boston-cas
 ```

2. Install `rvm` to manage ruby versions
 ```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
 ```

3. Install `ruby` and setup it up as the default ruby version for your shell.
 ```bash
$ cd /u/apps/boston-cas
$ rvm use --install --default .
 ```

4. Install `nodejs` (used to build assets) from apt
 ```bash
sudo apt-get install nodejs
 ```

5. Install `postgres` and the drivers we need from the offical apt repo and promote yourself to a postgres superuser
 ```bash
echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |   sudo apt-key add -
sudo apt-get install postgresql-9.5 libpq-dev
$ sudo -u postgres createuser -s `whoami`
 ```

### Install the App
Let the app finish setting itself up with `bin/setup`
 ```bash
bin/setup
 ```
