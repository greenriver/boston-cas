class MatchProgressUpdatesController < ApplicationController
  include HasMatchAccessContext
  include MatchShow
  include Decisions
  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!
  before_action :prep_for_show
  before_action :set_update

  def create
    @update.response = progress_params[:response].reject(&:blank?).uniq.join('; ')
    @update.client_last_seen = progress_params[:client_last_seen]
    @update.note = progress_params[:note]
    if @update.valid?
      @decision.set_stall_date
      @update.save
      Notifications::ProgressUpdateSubmitted.create_for_match!(@match)
    else
      flash[:error] = 'Unable to save your response'
    end
    if params[:notification_id]
      respond_with(@update, location: match_path(@match, notification_id: params[:notification_id]))
    else
      respond_with(@update, location: match_path(@match))
    end
  end

  def progress_params
    params.require(:status_update).
      permit(
        :client_last_seen,
        :note,
        response: [],
      )
  end

  def find_match!
    if params[:match_id].present?
      @match = match_scope.find(params[:match_id].to_i)
    else
      @match = match_scope.find(params[:id].to_i)
    end
  end

  def flash_interpolation_options
    { resource_name: 'Progress Update' }
  end
end
