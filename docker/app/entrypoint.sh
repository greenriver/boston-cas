#!/bin/sh

# Exit on any error
# set -e

# auto-export variables
set -a

if [[ "${EKS}" != "true" ]]
then
  echo Getting Role Info
  curl --silent 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI > role.info.log

  cd /app

  echo 'Getting secrets for the environment...'
  T1=`date +%s`
  bundle exec ./bin/download_secrets.rb > .env
  T2=`date +%s`
  echo "...secrets took $(expr $T2 - $T1) seconds"

  echo Sourcing environment
  . .env
fi

echo 'Constructing an ERB-free database.yml file...'
T1=`date +%s`
bundle exec ./bin/materialize.database.yaml.rb
T2=`date +%s`
echo "...database materialize took $(expr $T2 - $T1) seconds"

echo 'Setting Timezone'
cp /usr/share/zoneinfo/$TIMEZONE /app/etc-localtime
echo $TIMEZONE > /etc/timezone

if [ "$CONTAINER_VARIANT" == "dj" ]; then
  if [[ "${ENABLE_DJ_METRICS}" == "true" ]] ; then
    echo "Starting metrics server"
    # not cluster mode with 5 threads
    bundle exec puma --no-config -w 0 -t 1:5 /app/dj-metrics/config.ru &
  fi

  echo "Calling: $@"
  exec "$@"
fi

# echo 'Syncing the client assets from s3...'
# T1=`date +%s`
# ./bin/sync_app_assets.rb
# T2=`date +%s`
# echo "...sync_app_assets 1 took $(expr $T2 - $T1) seconds"

echo 'Clobbering assets...'
T1=`date +%s`
./bin/rake assets:clobber && mkdir -p ./public/assets
T2=`date +%s`
echo "...clobbering took $(expr $T2 - $T1) seconds"

T1=`date +%s`
ASSET_CHECKSUM=$(ASSETS_PREFIX=${ASSETS_PREFIX} ./bin/asset_checksum) # This should return the same hash as the call in asset_compiler.rb
T2=`date +%s`
echo "...checksumming took $(expr $T2 - $T1) seconds"

if grep 'Access denied' asset.checksum.log > /dev/null 2>&1; then
  echo "Looks like you cannot access the assets bucket. Check your IAM permissions"
fi

# echo "asset.checksum.log"
# cat asset.checksum.log

echo "Using ASSET_CHECKSUM [${ASSET_CHECKSUM}]"

echo 'Pulling down the compiled assets...' # Using ASSETS_PREFIX from .env and ASSET_CHECKSUM from above.
cd ./public/assets

if [ "$CONTAINER_VARIANT" == "deploy" ]; then
  bundle exec /app/bin/wait_for_compiled_assets.rb || exit 1
fi

T1=`date +%s`
ASSETS_PREFIX="${ASSETS_PREFIX}/${ASSET_CHECKSUM}" ASSETS_BUCKET_NAME=openpath-precompiled-assets UPDATE_ONLY=true bundle exec /app/bin/sync_app_assets.rb
T2=`date +%s`
echo "...pulling compiled assets took $(expr $T2 - $T1) seconds"
cd ../..

# Then exec the container's main process (what's set as CMD in the Dockerfile).
echo "Calling: $@"
exec "$@"
