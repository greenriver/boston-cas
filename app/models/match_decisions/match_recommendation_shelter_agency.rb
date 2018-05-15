module MatchDecisions
  class MatchRecommendationShelterAgency < Base
    
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::AcceptsNotWorkingWithClientReason

    # proxy for client.release_of_information
    attr_accessor :release_of_information
    # javascript toggle
    attr_accessor :working_with_client
    # validate :note_present_if_status_declined
    validate :validate_not_working_reasons_present_if_not_working_with_client
    validate :validate_client_last_seen_date_present_if_not_working_with_client
    validate :release_of_information_present_if_match_accepted
    validate :spoken_with_services_agency_and_cori_release_submitted_if_accepted

    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then "New Match Awaiting #{_('Shelter Agency')} Review"
      when :acknowledged then "Match acknowledged by #{_('Shelter Agency')}.  In review"
      when :accepted then "Match accepted by #{_('Shelter Agency')}. Client has signed release of information, spoken with services agency and submitted a CORI release form"
      when :not_working_with_client then "#{_('Shelter Agency')} no longer working with client"
      when :expiration_update then "New Match Awaiting #{_('Shelter Agency')} Review"
      when :declined then decline_status_label
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    private def decline_status_label
      [
        "Match declined by #{_('Shelter Agency')}. Reason: #{decline_reason_name}",
        not_working_with_client_reason_status_label
      ].join ". "
    end
    

    def step_name
      "#{_('Shelter Agency')} Initial Review of Match Recommendation"
    end

    def actor_type
      _('Shelter Agency')
    end

    def contact_actor_type
      :shelter_agency_contacts
    end
    
    def statuses
      {
        pending: 'Pending', 
        acknowledged: 'Acknowledged', 
        accepted: 'Accepted', 
        declined: 'Declined', 
        not_working_with_client: 'Pending', 
        canceled: 'Canceled',
        expiration_update: 'Pending',
        back: 'Pending',
      }
    end
    
    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def initialize_decision! send_notifications: true
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::MatchRecommendationClient
        m << Notifications::MatchRecommendationShelterAgency
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact:
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? || 
      contact.in?(match.shelter_agency_contacts)
    end

    private def note_present_if_status_declined
      if note.blank? && status == 'declined'
        errors.add :note, 'Please note why the match is declined.'
      end
    end

    private def decline_reason_scope
      MatchDecisionReasons::ShelterAgencyDecline.all
    end


    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def acknowledged
      end

      def accepted
        # Only update the client's release_of_information attribute if we just set it
        if @decision.release_of_information == '1'
          match.client.update_attribute(:release_of_information, Time.now)
        end
        @decision.next_step.initialize_decision!
      end
      
      def declined
        match.confirm_shelter_agency_decline_dnd_staff_decision.initialize_decision!
      end

      def not_working_with_client
        
      end

      def expiration_update
        
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end 
    end
    private_constant :StatusCallbacks

    # Override default behavior to send additional notification to DND contacts
    # if status = 'not_working_with_client'
    def record_action_event! contact:
      if status == 'not_working_with_client'
        Notifications::NoLongerWorkingWithClient.create_for_match! match
        decision_action_events.create! match: match, contact: contact, action: status, note: note, not_working_with_client_reason_id: not_working_with_client_reason_id, client_last_seen_date: client_last_seen_date
      elsif status == 'expiration_update'
        # Make note of the new expiration
      else
        decision_action_events.create! match: match, contact: contact, action: status, note: note
      end
    end
    
    private def validate_not_working_reasons_present_if_not_working_with_client
      if not_working_with_client_reason.blank? && status == 'not_working_with_client'
        errors.add :not_working_with_client_reason_id, 'you must specify at least one reason if you are no longer working with the client'
      end
    end

    private def validate_client_last_seen_date_present_if_not_working_with_client
      if not_working_with_client_reason.present? && client_last_seen_date.blank?
        errors.add :client_last_seen_date, 'must be filled in if you are no longer working with the client'
      end
    end

    private def release_of_information_present_if_match_accepted
      # if the Shelter Agency has just indicated a release has been signed:
      # release_of_information = '1'
      # if the client previously signed the release 
      # release_of_information = Time
      if status == 'accepted' && release_of_information == '0'
        errors.add :release_of_information, 'Client must provide a release of information to move forward in the match process'
      end
    end

    private def spoken_with_services_agency_and_cori_release_submitted_if_accepted
      if status == 'accepted' 
        if ! client_spoken_with_services_agency
          errors.add :client_spoken_with_services_agency, 'Communication with the services agency is required.'
        end
        if Config.get(:require_cori_release) && ! cori_release_form_submitted
         errors.add :cori_release_form_submitted, 'A CORI release form is required.'
        end
      end
    end

    private def decline_reason_blank?
      decline_reason.blank? && not_working_with_client_reason.blank?
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :client_last_seen_date, 
        :release_of_information, 
        :working_with_client, 
        :client_spoken_with_services_agency, 
        :cori_release_form_submitted,
        :shelter_expiration
      )
    end
  end
end

