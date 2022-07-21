require 'dotenv'
require 'active_support/core_ext/object/blank'
Dotenv.load('.env', '.env.local')
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
tasks = [
  {
    task: 'cas:daily',
    frequency: 1.day,
    at: '5:00 am',
    interruptable: false,
  },
  {
    task: 'cas:populate_match_census',
    frequency: 1.day,
    at: '5:15 am',
    interruptable: false,
  },
  {
    task: 'warehouse:sync_ce_data',
    frequency: 1.day,
    at: '5:30 am',
    interruptable: false,
  },
  {
    task: 'cas:request_status_updates',
    frequency: 1.day,
    at: '7:30 am',
    interruptable: true,
  },
  {
    task: 'messages:daily',
    frequency: 1.day,
    at: '4:00 am',
    interruptable: true,
  },
  {
    task: 'cas:update_clients',
    frequency: 5.minutes,
    interruptable: true,
  },
  {
    task: 'cas:hourly',
    frequency: 1.hours,
    interruptable: true,
  },
]

job_type :rake_spot, 'cd :path && :environment_variable=:environment bundle exec rake :task --silent #capacity_provider:spot'

tasks.each do |task|
  next if task.key?(:trigger) && ! task[:trigger]

  options = {}
  options[:at] = task[:at] if task[:at].present?
  every task[:frequency], options do
    if ENV['ECS'] == 'true' && task[:interruptable]
      rake_spot task[:task]
    else
      # For now, move all cron tasks to the "spot" capacity provider
      rake_spot task[:task]
      # rake task[:task]
    end
  end
end
