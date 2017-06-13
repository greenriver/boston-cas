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
end