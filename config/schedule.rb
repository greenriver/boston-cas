# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, '/path/to/my/cron_log.log'
#
# every 2.hours do
#   command '/usr/bin/some_great_command'
#   runner 'MyModel.some_method'
#   rake 'some:great:rake:task'
# end
#
# every 4.days do
#   runner 'AnotherModel.prune_old_records'
# end

# Learn more: http://github.com/javan/whenever
every 1.day, at: '5:00 am' do
  rake 'cas:daily'
  rake 'cas:populate_match_census'
  rake 'warehouse:sync_ce_data'
end

every 1.day, at: '4:00 am' do
  rake 'messages:daily'
end

every 5.minutes do
  rake 'cas:update_clients'
end

every 1.day, at: '7:30am' do
  rake 'cas:request_status_updates'
end

every 1.hour do
  rake 'cas:hourly'
end
