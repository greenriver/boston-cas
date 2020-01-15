###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
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
