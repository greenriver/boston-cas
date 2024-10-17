Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 15.minutes
if Rails.env.development? && ! ENV['RAILS_LOG_TO_STDOUT'] == 'true'
  Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
else
  Delayed::Worker.logger = Logger.new($stdout)
end
