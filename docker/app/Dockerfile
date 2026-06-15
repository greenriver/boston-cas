# syntax = docker/dockerfile:1-experimental

###########################################
## Dependencies just needed during build ##
###########################################
ARG BUILD_TAG
FROM ruby:${BUILD_TAG} AS cert

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  openssl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /

RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
  -subj "/C=US/ST=Vermont/L=Brattleboro/O=greenriver/CN=www.example.com" \
  -keyout key.pem -out cert.pem


#########################
## global dependencies ##
#########################

ARG BUILD_TAG
FROM ruby:${BUILD_TAG} AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USER_ID=10000
ARG GROUP_ID=10000
ARG BUNDLER_VERSION=2.7.1

LABEL "app"=open-path-cas
LABEL "ruby-version"=4.0.2

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV GEM_HOME=/bundle
ENV BUNDLE_JOBS=4
ENV BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH
ENV BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /app/bin:$BUNDLE_BIN:$PATH
# https://github.com/sass/sassc-ruby/issues/146#issuecomment-542288556
# core dumps during precompile on github when using the pre-cache image pulled
# from ECR
ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Allow tls connection to database with verification
COPY docker/app/us-east-1-bundle.pem  /etc/ssl/certs/us-east-1-bundle.pem

RUN groupadd -g ${GROUP_ID} app-user \
  && useradd -l -u ${USER_ID} -g app-user -s /bin/bash -d /home/app-user -m app-user \
  && mkdir /app /bundle \
  && chown app-user:app-user /bundle /app

# Add PostgreSQL official repository, NodeJS and Yarn repositories
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates lsb-release gnupg \
  && sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
  && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg \
  && curl -fsSL https://deb.nodesource.com/setup_24.x | bash -s -- -y \
  && apt-get update \
  && apt-get remove -y nodejs \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
  awscli \
  bash \
  build-essential \
  dbus \
  dbus-user-session \
  file \
  fonts-dejavu \
  fonts-droid-fallback \
  fonts-freefont-ttf \
  fonts-liberation \
  git \
  gnupg-agent \
  gpg \
  imagemagick \
  libcurl4 \
  libcurl4-openssl-dev \
  libffi-dev \
  libfreetype-dev \
  libfreetype6 \
  libgeos-dev \
  libglib2.0-0 \
  libharfbuzz-dev \
  libheif1 \
  libicu-dev \
  libmagic-dev \
  libmagic1 \
  libpq-dev \
  libx11-6 \
  libxext6 \
  libxml2-dev \
  libxrender1 \
  libxslt1-dev \
  libyaml-dev \
  locales-all \
  nodejs \
  p7zip-full \
  packagekit \
  packagekit-tools \
  policykit-1 \
  poppler-utils \
  postgresql-client \
  procps \
  pinentry-tty \
  shared-mime-info \
  software-properties-common \
  tar \
  tini \
  tzdata \
  vim \
  && rm -rf /var/lib/apt/lists/* \
  && if [ "$(uname -m)" = "aarch64" ]; then \
      ln -s /usr/lib/aarch64-linux-gnu/libproj.so /usr/lib/libproj.so.20; \
    else \
      ln -s /usr/lib/x86_64-linux-gnu/libproj.so /usr/lib/libproj.so.20; \
    fi \
  && npm install -g yarn@1.22.22

WORKDIR /app

# rexml: CVE-2025-58767, rack: CVE in system gem shipped with base image — both must be explicitly updated since they're bundled with ruby
# gem cleanup removes old gemspecs that vulnerability scanners (e.g. Trivy) would otherwise flag
RUN gem update --system \
  && gem update rexml rack erb net-imap \
  && gem cleanup rexml rack erb net-imap \
  && find /usr/local/lib/ruby/gems -path "*/specifications/default/erb-*.gemspec" -delete \
  && find /usr/local/lib/ruby/gems -path "*/specifications/default/net-imap-*.gemspec" -delete \
  && gem install bundler --version=${BUNDLER_VERSION} \
  && bundle config set --local path /bundle \
  && chown -R app-user:${GROUP_ID} /bundle \
  && echo 'America/New_York' > /etc/timezone \
  && chmod a+w /etc/timezone

USER ${USER_ID}

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

#########################################
## Stage/target for use in development ##
#########################################

FROM base AS dev-build

USER root

COPY docker/app/entrypoint.dev.sh /usr/bin/
COPY docker/app/entrypoint.spec.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.dev.sh"]

RUN git config --global --add safe.directory /app \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  neovim less docker.io python3 zsh openssh-client \
  && rm -rf /var/lib/apt/lists/*

USER ${USER_ID}

########################################
## Stage/target for use in production ##
########################################

FROM base AS prod-build

COPY docker/app/entrypoint.sh /usr/bin/
ENTRYPOINT ["tini", "--", "/usr/bin/entrypoint.sh"]

COPY --chown=app-user:${GROUP_ID} --from=cert /key.pem /cert.pem /app/config/
COPY --chown=app-user:${GROUP_ID} Gemfile Gemfile.lock ./

RUN bundle config without development test doc \
  && bundle install \
  && find /bundle -name "*.o" -exec rm {} \; \
  && find /bundle -name "*.c" -exec rm {} \;

COPY --chown=app-user:${GROUP_ID} package.json yarn.lock ./
RUN yarn install --frozen-lockfile \
  && yarn cache clean

COPY --chown=app-user:${GROUP_ID} . ./
COPY --chown=app-user:${GROUP_ID} sample.irbrc ./.irbrc
COPY --chown=app-user:${GROUP_ID} docker/app/dotenv.temporary ./.env
COPY --chown=app-user:${GROUP_ID} docker/app/REVISION ./
COPY --chown=app-user:${GROUP_ID} docker/app/GIT_BRANCH ./
COPY --chown=app-user:${GROUP_ID} docker/app/database.open-path-cas.yml ./config/database.yml

RUN rm -rf tmp/* \
  && mkdir -p tmp/pids locale var \
  && mkdir -p app/assets/stylesheets/theme/styles \
  && touch app/assets/stylesheets/theme/styles/_variables.scss \
  && RAILS_ENV=production ./bin/rake assets:precompile \
  && rm -rf tmp/* \
  && mkdir tmp/pids


# Trivy flags CVEs in npm's bundled node_modules (/usr/lib/node_modules/npm/node_modules),
# which are unreachable at runtime, so we drop the whole package managers here.
USER root
RUN rm -rf /usr/lib/node_modules/npm /usr/lib/node_modules/yarn \
  && rm -f /usr/bin/npm /usr/bin/npx /usr/bin/yarn /usr/bin/yarnpkg

USER ${USER_ID}
