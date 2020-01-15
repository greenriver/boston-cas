###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class Users::SessionsController < Devise::SessionsController
  #configure auto_session_timeout
  def active
    render_session_status
  end

  def timeout
    flash[:notice] = "Your session expired; you have been logged out."
    redirect_to root_path
  end
end
