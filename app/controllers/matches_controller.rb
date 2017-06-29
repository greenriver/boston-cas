class MatchesController < ApplicationController
  include HasMatchAccessContext

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!, only: [:show]

  def show
    @client = @match.client
    @opportunity = @match.opportunity
    current_decision = @match.current_decision
    if current_decision.try :accessible_by?, current_contact
      @decision = current_decision
    end
    if params[:notification_id].present?
      @notification = @access_context.notification
      # load previously failed status sumission if available
      @update = session[:match_status_update][params[:notification_id]].presence rescue nil
      session[:match_status_update] = nil
    end
  end
  
  def history
    @match = match_scope.find(params[:match_id])
    render layout: false
  end
  
  private

    def find_match!
      @match = match_scope.find(params[:id])
    end



end
