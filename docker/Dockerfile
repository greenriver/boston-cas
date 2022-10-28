# Based on https://github.com/ledermann/docker-rails/blob/develop/Dockerfile
ARG RUBY_VERSION
# NOTE FROM clears all ARGs
FROM ruby:$RUBY_VERSION-alpine3.15

ARG PG_MAJOR
ARG NODE_MAJOR
ARG BUNDLER_VERSION
ARG YARN_VERSION
ARG CHROMEDRIVER_VERSION
ARG ADDITIONAL_PACKAGES

ENV RAILS_ENV ${RAILS_ENV}
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

LABEL maintainer="elliot@greenriver.com"

RUN apk add --no-cache \
  nodejs yarn npm \
  tzdata \
  git \
  bash \
  freetds-dev \
  docker \
  openssh ctags zsh \
  icu icu-dev \
  curl libcurl curl-dev \
  imagemagick \
  libmagic file-dev file gcompat \
  build-base libxml2-dev libxslt-dev postgresql-dev \
  libgcc libstdc++ libx11 glib libxrender libxext libintl \
  ttf-dejavu ttf-droid ttf-freefont ttf-liberation \
  chromium nss freetype freetype-dev harfbuzz ca-certificates \
  lftp postgresql tmux postgis geos geos-dev proj proj-dev proj-util zip expect \
  shared-mime-info \
  vim less \
  tar \
  xz \
  python3 py3-pip \
  && git config --global --add safe.directory /app \
  && ln -s libproj.so.21.1.2 /usr/lib/libproj.so.20

RUN mkdir /app
WORKDIR /app

# Configure bundler and PATH
ENV LANG=C.UTF-8 \
  GEM_HOME=/bundle \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
  BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /app/bin:$BUNDLE_BIN:$PATH

# Install gems
ADD Gemfile* /app/

# Upgrade RubyGems and install required Bundler version
RUN gem update --system \
    && gem install bundler:$BUNDLER_VERSION \
    && bundle \
    && bundle exec rails webpacker:install \
    && yarn install

COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
