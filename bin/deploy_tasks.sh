#!/bin/bash

set -eo pipefail

echo Migrating with individual rake tasks

echo Migrating app database
T1=`date +%s`
rake db:migrate
T2=`date +%s`
echo "...rake db:migrate took $(expr $T2 - $T1) seconds"

echo 'Rules seeding'
T1=`date +%s`
rake cas_seeds:create_rules
T2=`date +%s`
echo "...rake cas_seeds:create_rules took $(expr $T2 - $T1) seconds"

echo 'Match decision reasons seeding'
T1=`date +%s`
rake cas_seeds:create_match_decision_reasons
T2=`date +%s`
echo "...rake cas_seeds:create_match_decision_reasons took $(expr $T2 - $T1) seconds"

echo 'Ensure all match routes exist'
T1=`date +%s`
rake cas_seeds:ensure_all_match_routes_exist
T2=`date +%s`
echo "...rake cas_seeds:ensure_all_match_routes_exist took $(expr $T2 - $T1) seconds"

echo 'Ensure all match prioritization schemes exist'
T1=`date +%s`
rake cas_seeds:ensure_all_match_prioritization_schemes_exist
T2=`date +%s`
echo "...rake cas_seeds:ensure_all_match_prioritization_schemes_exist took $(expr $T2 - $T1) seconds"

echo 'Stalled reasons seeding'
T1=`date +%s`
rake cas_seeds:stalled_reasons
T2=`date +%s`
echo "...rake cas_seeds:stalled_reasons took $(expr $T2 - $T1) seconds"

echo 'Mitigation reasons seeding'
T1=`date +%s`
rake cas_seeds:create_mitigation_reasons
T2=`date +%s`
echo "...rake cas_seeds:create_mitigation_reasons took $(expr $T2 - $T1) seconds"

echo 'General seeding'
T1=`date +%s`
rake db:seed
T2=`date +%s`
echo "...rake db:seed took $(expr $T2 - $T1) seconds"

echo 'Installing cron'
T1=`date +%s`
./config/deploy/docker/lib/cron_installer.rb
T2=`date +%s`
echo "..../cron_installer.rb took $(expr $T2 - $T1) seconds"

# keep this always at the end of this file
echo making interface aware this script completed
rake deploy:mark_deployment_id
echo ---DONE---
