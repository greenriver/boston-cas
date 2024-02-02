###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SystemStatusController < ApplicationController
  skip_before_action :authenticate_user!

  def ping
    Rails.logger.info 'Ping [info]'
    Rails.logger.debug 'Ping [debug]'
    render status: 200, plain: 'Ping'
  end

  # Provide a path for nagios or other system checker to determine if the system is
  # operational
  def operational
    user_count = User.all.count
    if user_count.positive?
      Rails.logger.info 'Operating system is operational'
      render plain: 'OK'
    else
      Rails.logger.info 'Operating system is not operational'
      render status: 500, plain: 'FAIL'
    end
  end

  def cache_status
    set_value = SecureRandom.hex(10)
    Rails.cache.write('cache-test', set_value)
    pulled_value = Rails.cache.read('cache-test')

    if set_value == pulled_value
      Rails.logger.info 'Cache is operational'
      render plain: 'OK'
    else
      Rails.logger.info 'Cache is not operational'
      render status: 500, plain: 'FAIL'
    end
  end

  def details
    status = 200

    set_value = SecureRandom.hex(10)
    Rails.cache.write('cache-test', set_value)
    pulled_value = Rails.cache.read('cache-test')
    cache_message = (set_value == pulled_value ? 'OK' : 'FAILED')

    status = 417 if cache_message != 'OK'

    db_message = 'UNKNOWN'
    begin
      db_message = (ApplicationRecord.connection.execute('select 1') ? 'OK' : 'FAILED')
    rescue StandardError
      db_message = 'FAILED'
    end
    status = 417 if db_message != 'OK'

    jobs_stats = {}
    jobs_message = 'OK'
    Delayed::Job.select('distinct queue').pluck(:queue).each do |queue|
      scope = Delayed::Job.where(queue: queue)
      enqueued = scope.where(failed_at: nil).count
      failed = scope.where.not(failed_at: nil).count

      if enqueued > 20
        jobs_message = 'QUEUE TOO BIG'
        status = 417
      elsif failed > 20
        jobs_message = 'TOO MANY FAILED'
        status = 417
      end

      jobs_stats[queue] = {
        enqueued: enqueued,
        failed: failed,
      }
    end

    cas = 'unknown'
    begin
      cas = ApplicationRecord.connection.migration_context.current_version
    rescue StandardError
      cas = 'unknown'
    end

    payload = {
      db: db_message,
      jobs_stats: jobs_stats,
      jobs_message: jobs_message,
      revision: Git.revision,
      branch: Git.branch,
      hostname: `hostname`.chomp,
      cache: cache_message,
      user_count_positive: User.all.any?,
      registered_deployment_id: Rails.cache.read('registered-deployment-id'),
      environment_deployment_id: ENV['DEPLOYMENT_ID'],
      last_migration: {
        cas: cas,
      },
    }

    render json: payload, status: status
  end
end
