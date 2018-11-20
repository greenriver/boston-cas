Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 15.minutes
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))

# Monkey patch so Delayed::Worker knows where it started
# Delayed::Worker::Deployment.deployed_to
module Delayed
  class Worker
    class Deployment
      def self.deployed_to
        Dir.glob(File.join(File.dirname(File.realpath(FileUtils.pwd)), '*')).max_by{|f| File.mtime(f)}
      end
    end
  end
end