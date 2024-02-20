# syntax = docker/dockerfile:1-experimental

###########################################
## Dependencies just needed during build ##
###########################################
ARG BUILD_TAG
FROM ruby:${BUILD_TAG} AS cert

RUN apk add --no-cache \
  openssl

WORKDIR /

RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=US/ST=Vermont/L=Brattleboro/O=greenriver/CN=www.example.com" \
    -keyout key.pem -out cert.pem


#########################
## global dependencies ##
#########################

ARG BUILD_TAG
FROM ruby:${BUILD_TAG} AS base
ARG USER_ID=10000
ARG GROUP_ID=10000
ARG BUNDLER_VERSION=2.4.13

LABEL "app"=open-path-cas
LABEL "ruby-version"=3.1.4

ENV LANG=C.UTF-8
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
# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV GROVER_NO_SANDBOX=true
ENV CHROMIUM_PATH=/usr/bin/chromium-browser

# Allow tls connection to database with verification
COPY docker/app/us-east-1-bundle.pem  /etc/ssl/certs/us-east-1-bundle.pem
# Deprecated and soon to expire
COPY docker/app/rds-combined-ca-bundle.pem /etc/ssl/certs/rds-combined-ca-bundle.pem

SHELL [ "/bin/ash", "-o", "pipefail", "-c" ]
RUN addgroup -g ${GROUP_ID} app-user || echo ok \
   && grep ":${GROUP_ID}:" /etc/group | cut -f1 -d: > /.group_name \
   && adduser -u ${USER_ID} -G "$(cat /.group_name)" -h /home/app-user -D app-user \
   && mkdir /app /bundle \
   && chown app-user:${GROUP_ID} /bundle /app

RUN apk update \
  && apk upgrade --no-cache \
  && apk add --no-cache \
     nodejs yarn \
     tzdata \
     git \
     bash \
     icu icu-dev \
		 py3-pip \
     curl libcurl curl-dev \
     libmagic file-dev file \
     build-base libxml2-dev libxslt-dev postgresql-dev tmux postgresql shared-mime-info \
     tar xz \
  && git config --global --add safe.directory /app

RUN pip3 install --no-cache-dir awscli

WORKDIR /app

RUN gem update --system \
  && gem install bundler --version=${BUNDLER_VERSION} \
	&& bundle config set --local path /bundle \
  && chown -R app-user:${GROUP_ID} /bundle \
	&& echo 'America/New_York' > /etc/timezone \
	&& chmod a+w /etc/timezone

USER app-user

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
  && apk update \
  && apk add --no-cache \
		alien \
		curl \
		docker \
		less \
		libpng-dev \
		neovim \
		nodejs \
		openssh \
		unzip \
		vim \
		xvfb \
		zsh \
  && rm -rf /var/cache/apk/*

USER app-user

########################################
## Stage/target for use in production ##
########################################

FROM base AS prod-build

COPY docker/app/entrypoint.sh /usr/bin/
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

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
