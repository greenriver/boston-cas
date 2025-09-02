###
# Copyright 2016 - 2025 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :compose_activity, except: [:active]
  after_action :log_activity, except: [:active]

  # configure auto_session_timeout
  def active
    render_session_status
  end

  def timeout
    flash[:notice] = 'Your session expired; you have been logged out.'
    redirect_to root_path
  end
end
