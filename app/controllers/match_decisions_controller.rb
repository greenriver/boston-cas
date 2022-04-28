###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

class MatchDecisionsController < ApplicationController
  include HasMatchAccessContext
  include Decisions
  include ContactEditPermissions
  include MatchBuildingAndUnit

  skip_before_action :authenticate_user!
  before_action :require_match_access_context!
  before_action :find_match!
  before_action :find_decision!
  before_action :authorize_decision!
  before_action :authorize_notification_recreation!, only: [:recreate_notifications]
  before_action :set_client, only: [:show, :update]
  before_action :set_contacts, only: [:show, :update]

  def show
    @opportunity = @match.opportunity
    @program = @match.program
    @sub_program = @match.sub_program
    @types = MatchRoutes::Base.match_steps
    render 'matches/show'
  end

  def update
    @program = @match.program
    @sub_program = @match.sub_program
    @types = MatchRoutes::Base.match_steps

    @match_contacts.update match_contacts_params if params[:match_contacts].present?
    if !@decision.editable?
      flash[:error] = 'Sorry, a response has already been recorded and this step is now locked.'
      redirect_to access_context.match_decision_path(@match, @decision)

    elsif @match.closed?
      flash[:error] = 'Sorry, that match has already been closed.'
      redirect_to access_context.match_path(@match)

    # If we've been asked to park the client and match is accepted
    elsif decision_params[:prevent_matching_until].present? && decision_params[:status] == 'accepted'
      flash[:error] = 'Sorry, if the client is parked, you cannot accept this match recommendation at this time.'
      render 'matches/show'

    # If we are overriding a decline, we must have a note
    elsif decision_params[:status].in?(['decline_overridden', 'decline_overridden_returned']) && decision_params[:note].blank?
      flash[:error] = 'An override reason is required for to override a decline.'
      render 'matches/show'

    # If cancel reason is provided and match is declined or accepted
    elsif decision_params[:administrative_cancel_reason_id].present? && decision_params[:status] == 'accepted' ||
          decision_params[:administrative_cancel_reason_id].present? && decision_params[:status] == 'declined'
      flash[:error] = 'Sorry, if a cancel reason is specified, you can only cancel this match recommendation.'
      render 'matches/show'

    # If decline reason is provided and match is canceled or accepted
    elsif decision_params[:decline_reason_id].present? && decision_params[:status] == 'accepted' ||
          decision_params[:decline_reason_id].present? && decision_params[:status] == 'canceled'
      flash[:error] = 'Sorry, if a decline reason is specified, you can only decline this match recommendation.'
      render 'matches/show'

    # If cancel reason is NOT provided and match is canceled
    elsif decision_params[:administrative_cancel_reason_id].blank? && decision_params[:status] == 'canceled'
      flash[:error] = 'Sorry, you must provide a cancel reason to cancel this match.'
      render 'matches/show'

    # If disable opportunity is set and no cancel reason is set
    elsif decision_params[:disable_opportunity] == '1' && decision_params[:administrative_cancel_reason_id].blank?
      flash[:error] = 'Sorry, you can only disable a vacancy when cancelling a match'
      render 'matches/show'

    elsif @decision.update(decision_params)
      # Wrapped in a transaction to prevent the match match engine (which runs in parallel) from seeing
      # partial updates
      @decision.class.transaction do
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
              note: note,
            )
          end
        end

        if can_delete_matches? && decision_params[:status] == 'destroy'
          opportunity = @match.opportunity
          @match.reset_and_destroy!
          redirect_to opportunity_matches_path(opportunity)
        else
          @decision.record_action_event! contact: current_contact
          @decision.record_updated_unit! unit_id: decision_params[:unit_id], contact_id: current_contact.id

          # If we've been asked to park the client do so.  This will set the match status to canceled
          # Don't run the status callbacks unless we aren't parking as they will
          # re-enable the client for matching
          prevent_matching_until = decision_params[:prevent_matching_until]&.to_date
          if can_reject_matches? && prevent_matching_until.present? && prevent_matching_until > Date.current
            @match.client.unavailable(permanent: false, contact_id: current_contact.id, cancel_specific: @match, expires_at: prevent_matching_until)
          else
            @decision.run_status_callback!
          end

          if decision_params[:disable_opportunity] == '1'
            voucher = @match.opportunity.voucher
            voucher.update(available: false) if voucher.present?
            @match.opportunity.update(available: false, available_candidate: false)
          end

          # Note this was done on-behalf of someone else
          # don't make note if the action is stepping back or setting the expiration
          if @decision.contact_actor_type.present? && decision_params[:status] != 'back' && decision_params[:shelter_expiration].blank?
            @decision.notify_contact_of_action_taken_on_behalf_of contact: current_contact unless current_contact.in?(@match.send(@decision.contact_actor_type))
          end
          flash[:notice] = 'Thank you, your response has been entered.' unless request.xhr?
          redirect_to access_context.match_path(@match, redirect: 'true')
        end
      end
    else
      flash[:error] = "Please review the form problems below.<br /> #{@decision.errors.full_messages.join('; ')}"
      render 'matches/show'
    end
  end

  def recreate_notifications
    if @decision.editable?
      flash[:notice] = 'Recreated notifications for this step'
      @decision.recreate_notifications_for_this_step
    else
      flash[:alert] = 'Unable to recreate notifications for this step, it is now locked.'
    end
    redirect_to access_context.match_decision_path(@match, @decision, redirect: 'true')
  end

  private def find_match!
    @match = match_scope.find params[:match_id]
  end

  private def set_client
    @client = @match.client
  end

  private def set_contacts
    @current_contact = current_contact
    @match_contacts = @match.match_contacts
  end

  private def find_decision!
    @decision = @match.decision_from_param(params[:id])
  end

  private def authorize_decision!
    return if @decision&.accessible_by?(current_contact) || @decision&.declineable_by?(current_contact)

    flash[:alert] = 'Sorry, you are not authorized to access that.'
    redirect_to access_context.match_path(@match)
  end

  private def authorize_notification_recreation!
    return if can_recreate_this_decision?

    flash[:alert] = 'Sorry, you are not authorized to access that.'
    redirect_to access_context.match_path(@match)
  end

  private def decision_params
    @decision.whitelist_params_for_update params
  end

  private def match_contacts_params
    base_params = params[:match_contacts] || ActionController::Parameters.new
    base_params.permit(
      shelter_agency_contact_ids: [],
      housing_subsidy_admin_contact_ids: [],
      dnd_staff_contact_ids: [],
      client_contact_ids: [],
      ssp_contact_ids: [],
      hsp_contact_ids: [],
      do_contact_ids: [],
    ).tap do |result|
      if current_contact.user_can_edit_match_contacts?
        result[:shelter_agency_contact_ids] ||= []
        result[:client_contact_ids] ||= []
        result[:dnd_staff_contact_ids] ||= []
        result[:housing_subsidy_admin_contact_ids] ||= []
        result[:ssp_contact_ids] ||= []
        result[:hsp_contact_ids] ||= []
        result[:do_contact_ids] ||= []
      elsif hsa_can_edit_contacts?
        # only allow editing of the hsa contacts
        result[:shelter_agency_contact_ids] ||= @match.shelter_agency_contact_ids
        result[:client_contact_ids] ||= @match.client_contact_ids
        result[:dnd_staff_contact_ids] ||= @match.dnd_staff_contact_ids
        result[:housing_subsidy_admin_contact_ids] ||= []
        result[:ssp_contact_ids] ||= @match.ssp_contact_ids
        result[:hsp_contact_ids] ||= @match.hsp_contact_ids
        result[:do_contact_ids] ||= @match.do_contact_ids

        # always add self
        result[:housing_subsidy_admin_contact_ids] << current_contact.id
      end
    end
  end
end
