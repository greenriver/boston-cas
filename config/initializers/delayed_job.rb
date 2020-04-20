Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 15.minutes
if ENV['RAILS_LOG_TO_STDOUT'] == 'true'
  Delayed::Worker.logger = Logger.new(STDOUT)
else
  Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
end

# Monkey patch so Delayed::Worker knows where it started
# Delayed::Worker::Deployment.deployed_to
module Delayed
  class Worker
    class Deployment
      def self.deployed_to
        if Rails.env.development?
          File.realpath(FileUtils.pwd)
        else
          Dir.glob(File.join(File.dirname(File.realpath(FileUtils.pwd)), '*')).max_by{|f| File.mtime(f)}
        end
      end
    end
  end
end
