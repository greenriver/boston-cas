#!/usr/bin/bash

# Exit on any error
# set -e

# auto-export variables
set -a

if [[ "${EKS}" != "true" ]]; then
  echo Getting Role Info
  curl --silent 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI >role.info.log

  cd /app

  echo 'Getting secrets for the environment...'
  T1=$(date +%s)
  bundle exec ./bin/download_secrets.rb >.env
  if [ ! -f .env ]; then
    echo "Failed to create .env file"
    exit 1
  fi
  T2=$(date +%s)
  echo "...secrets took $(expr $T2 - $T1) seconds"

  echo Sourcing environment
  . /app/.env
fi

echo 'Constructing an ERB-free database.yml file...'
T1=$(date +%s)
bundle exec ./bin/materialize.database.yaml.rb
T2=$(date +%s)
echo "...database materialize took $(expr $T2 - $T1) seconds"

echo 'Setting Timezone'
cp /usr/share/zoneinfo/$TIMEZONE /app/etc-localtime
echo $TIMEZONE >/etc/timezone

# Target web containers for release tag resolution.
case "$CONTAINER_VARIANT" in
  '' | web)
    echo 'Resolving release tag from the deployed commit'
    bundle exec ruby ./lib/util/git/release_resolver.rb || echo 'release resolution failed; continuing'
    ;;
  *)
    echo "Skipping release tag resolution on $CONTAINER_VARIANT container"
    ;;
esac

if [[ "$CONTAINER_VARIANT" == "dj" ]]; then
  if [[ "${ENABLE_DJ_METRICS}" = "true" ]]; then
    echo "Starting metrics server"
    # not cluster mode with 5 threads
    bundle exec puma --no-config -w 0 -t 1:5 /app/dj-metrics/config.ru &
  fi

  echo "Calling: $@"
  exec "$@"
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
echo "Calling: $@"
exec "$@"
