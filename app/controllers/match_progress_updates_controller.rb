class MatchProgressUpdatesController < ApplicationController
  include HasMatchAccessContext
  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!
  before_action :set_update

  def update
    update_params = progress_params
    update_params[:response] = update_params[:response].reject(&:blank?).uniq.join('; ')
    update_params[:submitted_at] = Time.now
    begin
      @update.assign_attributes(update_params)
      @update.submit!
      Notifications::ProgressUpdateSubmitted.create_for_match!(@match)
    rescue Exception => e
      flash[:error] = "Unable to save your response: #{e.message}"
      session[:match_status_update] = {
        params[:notification_id] => @update
      }
    end
    redirect_to notification_match_path(id: @match.id, notification_id: @update.notification.code)
  end

  def progress_params
    params.require(:match_progress_updates).
      permit(
        :client_last_seen,
        :note,
        response: []
      )
  end

  def find_match!
    if params[:match_id].present?
      @match = match_scope.find(params[:match_id].to_i)
    else
      @match = match_scope.find(params[:id].to_i)
    end
  end

  def set_update
    # we may have arrived here from a previous notification
    # if we can't find an update based on the current notification, 
    # attempt to find one via our contact id and the match
    @update = MatchProgressUpdates::Base.joins(:notification).
      where(notifications: {code: params[:notification_id], client_opportunity_match_id: @match.id}).first
    if @update.blank?
      @update = MatchProgressUpdates::Base.where(
        contact_id: current_contact.id, 
        match_id: @match.id,
        submitted_at: nil
      ).joins(:notification).first
    end
  end
end
