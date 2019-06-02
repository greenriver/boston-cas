###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
###

class ReissueRequestsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_notification

  def show
    @match = @notification.match
    return unless @match.present? && @notification.decision.present?
    # this no longer re-issues requests, it simply keeps notifications from working forever
    
  end

  private
    def set_notification
      @notification = Notifications::Base.find_by code: params[:notification_id]
    end

    def reissue_request_params
      params.require(:notification_id)
    end

end