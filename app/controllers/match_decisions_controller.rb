class MatchDecisionsController < ApplicationController
  include HasMatchAccessContext

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!
  before_action :find_decision!
  before_action :authorize_decision!
  
  def show
    @client = @match.client
    @opportunity = @match.opportunity
    if params[:notification_id].present?
      @notification = @access_context.notification
    end
    render 'matches/show'
  end
  
  def update
    if !@decision.editable?
      flash[:error] = 'Sorry, a response has already been recorded and this step is now locked.'
      redirect_to access_context.match_decision_path(@match, @decision)
      
    elsif @match.closed?
      flash[:error] = 'Sorry, that match has already been closed.'
      redirect_to access_context.match_path(@match)
      
    # If expiration date is provided and match is declined
    elsif decision_params[:shelter_expiration].present? && decision_params[:status] == "declined" 
      flash[:error] = 'Sorry, you cannot decline a match if you have provided an expiration date.'
      render 'matches/show'
      
    # If we've been asked to park the client and match is accepted 
    elsif decision_params[:prevent_matching_until].present? && decision_params[:status] == "accepted" 
      flash[:error] = 'Sorry, if the client is parked, you cannot accept this match recommendation at this time.'
      render 'matches/show'
    
    # If cancel reason is provided and match is declined or accepted
    elsif decision_params[:administrative_cancel_reason_id].present? && decision_params[:status] == "accepted" || 
          decision_params[:administrative_cancel_reason_id].present? && decision_params[:status] == "declined" 
      flash[:error] = 'Sorry, if a cancel reason is specified, you can only cancel this match recommendation.'
      render 'matches/show'
    
    # If decline reason is provided and match is canceled or accepted
    elsif decision_params[:decline_reason_id].present? && decision_params[:status] == "accepted" || 
          decision_params[:decline_reason_id].present? && decision_params[:status] == "canceled" 
      flash[:error] = 'Sorry, if a decline reason is specified, you can only decline this match recommendation.'
      render 'matches/show'

    elsif @decision.update(decision_params)
      # If we are expiring the match for shelter agencies
      if can_reject_matches? && decision_params[:shelter_expiration].present?
        old_expiration = @match.shelter_expiration
        new_expiration = decision_params[:shelter_expiration]
        @match.update(shelter_expiration: new_expiration)
        if old_expiration.blank? || old_expiration.to_date != new_expiration.to_date
          note = "Shelter review expiration date set to #{new_expiration}."
          MatchEvents::ExpirationChange.create!(
            match_id: @match.id,
            contact_id: current_contact.id, 
            note: note
          )
        end
      end
      @decision.record_action_event! contact: current_contact
      @decision.run_status_callback!
      if @decision.contact_actor_type.present?
        unless current_contact.in?(@match.send(@decision.contact_actor_type))
          @decision.notify_contact_of_action_taken_on_behalf_of contact: current_contact
        end
      end
      flash[:notice] = "Thank you, your response has been entered." unless request.xhr?
      # If we've been asked to park the client
      if can_reject_matches? && decision_params[:prevent_matching_until].present?
        if decision_params[:prevent_matching_until].to_date > Date.today
          client = @match.client
          client.update(prevent_matching_until: decision_params[:prevent_matching_until].to_date)
          client.unavailable(permanent: false)
        end
      end
      redirect_to access_context.match_path(@match, redirect: "true")
    
    else
      flash[:error] = "Please review the form problems below."
      render 'matches/show'
    end
  end

  def recreate_notifications
    if @decision.editable?
      flash[:notice] = "Recreated notifications for this step"
      @decision.recreate_notifications_for_this_step
      redirect_to access_context.match_decision_path(@match, @decision, redirect: "true")
    else
      flash[:alert] = "Unable to recreate notifications for this step, it is now locked."
    end
  end

  private

    def find_match!
      @match = match_scope.find params[:match_id]
    end

    def find_decision!
      @decision = @match.decision_from_param params[:id]
    end
    
    def authorize_decision!
      unless @decision.accessible_by? current_contact
        flash[:alert] = 'Sorry, you are not authorized to access that.'
        redirect_to access_context.match_path(@match)
      end
    end
    
    def decision_params
      @decision.whitelist_params_for_update params
    end

end
