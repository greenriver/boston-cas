###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # configure auto_session_timeout
  def active
    render_session_status
  end

  def timeout
    flash[:notice] = 'Your session expired; you have been logged out.'
    redirect_to root_path
  end
end
