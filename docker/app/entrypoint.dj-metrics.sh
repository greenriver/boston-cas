#!/bin/sh

echo 'Setting Timezone'
cp /usr/share/zoneinfo/$TIMEZONE /app/etc-localtime
echo $TIMEZONE > /etc/timezone

cd /app/dj-metrics

export BUNDLE_GEMFILE=../Gemfile

exec bundle exec rackup --host 0.0.0.0
