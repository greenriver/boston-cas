class ReissueRequestsController < ApplicationController
  before_action :set_notification

  def show
    @match = @notification.match
    # might get here because:
    # 1. Expired token and step not yet complete (@notification.decision.editable? == true)
    #   This link has expired, 
    #   DND has been prompted to reissue an email notification to you with a new expiring link.  
    # 2. Expired token and step already complete (@notification.decision.editable? == false)
    #   Action has already been taken on this step on <date>, a new email notification will be 
    #   issued if you are involved in future steps.
    #   Show Current Step assigned to block on page
    if @notification.decision.editable?
      @reissue_request = ::ReissueRequest.where(notification: @notification).first_or_create
    end
  end

  private
    def set_notification
      @notification = Notifications::Base.find_by code: params[:notification_id]
    end

    def reissue_request_params
      params.require(:notification_id)
    end

end