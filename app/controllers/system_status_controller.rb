###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class SystemStatusController < ApplicationController
  skip_before_action :authenticate_user!

  # Provide a path for nagios or other system checker to determine if the system is
  # operational
  def operational
    user_count = User.all.count
    if user_count > 0
      render plain: 'OK'
    else
      render status: 500, plain: 'FAIL'
    end
  end

  def cache_status
    set_value = SecureRandom.hex(10)
    Rails.cache.write('cache-test',  set_value)
    pulled_value = Rails.cache.read('cache-test')

    if set_value == pulled_value
      render plain: 'OK'
    else
      render status: 500, plain: 'FAIL'
    end
  end
end
