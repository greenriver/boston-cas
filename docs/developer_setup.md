# Developer Setup
The warehouse application consists of two parts:
1. The Rails Application Code
2. The Rails Application Database

## Setup Your Development Environment

1. Clone the git repository
```
git clone git@github.com:greenriver/boston-cas.git
```
2. GEM dependencies - you may need to install the following dependencies prior to running `bin/setup`.
```shell
brew install freetds
brew install icu4c
brew install openssl
```

3. Create a `.env` file and add values for each of the variables in the `config/*.yml` files.

4. You may experience issues with openssl, brew, postgres and rvm not playing nicely together.  The following should help with trouble shooting.  At the time of writing, we're looking for OpenSSL 1.1.x
```shell
ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION'
```

5. Run the setup file
```
cd boston-cas
bin/setup
```
