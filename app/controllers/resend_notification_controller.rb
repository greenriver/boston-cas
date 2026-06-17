###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

class ResendNotificationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_can_reissue_notifications!

  def show
    @notification = Notifications::Base.find_by code: params[:id]
    @notification.deliver
    redirect_to request.referer
  end
end
