class ReissueNotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_or_dnd_staff!
  before_action :set_reissue_notification, only: [:update, :destroy]

  # GET /reissue_notifications
  def index
    @reissue_notifications = ReissueNotification.where(reissued_at: nil)
  end

  # PATCH/PUT /reissue_notifications/1
  # Attempt to re-send the notification and then mark it sent
  def update
    reissue_notification
    p = {reissued_by: current_user.id, reissued_at: Time.now}
    if @reissue_notification.update(p)
      redirect_to reissue_notifications_url, notice: 'Notification was successfully re-issued.'
    else
      render :edit
    end
  end

  # DELETE /reissue_notifications/1
  def destroy
    @reissue_notification.destroy
    redirect_to reissue_notifications_url, notice: 'Notification request was successfully deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reissue_notification
      @reissue_notification = ReissueNotification.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def reissue_notification_params
      params[:reissue_notification]
    end

    def reissue_notification
      match = ClientOpportunityMatch.find(@reissue_notification.notification.client_opportunity_match_id)
      contact = Contact.find(@reissue_notification.notification.recipient_id)
      reissue_notification_type.recreate_for_match! match, contact
    end
    def reissue_notification_type
      @reissue_notification.notification.type.constantize
    end
end
