module MatchDecisions
  class MatchRecommendationShelterAgency < Base
    
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::AcceptsNotWorkingWithClientReason

    # validate :note_present_if_status_declined
    validate :validate_client_last_seen_date_present_if_not_working_with_client

    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then 'New Match Awaiting Shelter Agency Review'
      when :acknowledged then 'Match acknowledged by shelter agency.  In review'
      when :accepted then 'Match accepted by shelter agency'
      when :declined then decline_status_label 
      end
    end

    private def decline_status_label
      [
        "Match declined by shelter agency. Reason: #{decline_reason_name}",
        not_working_with_client_reason_status_label
      ].join ". "
    end
    

    def step_name
      'Shelter Agency Initial Review of Match Recommendation'
    end

    def actor_type
      'Shelter Agency'
    end
    
    def statuses
      {pending: 'Pending', acknowledged: 'Acknowledged', accepted: 'Accepted', declined: 'Declined'}
    end
    
    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def initialize_decision!
      update status: 'pending'
      Notifications::MatchRecommendationShelterAgency.create_for_match! match
    end

    def accessible_by? contact
      contact.user_admin? ||
      contact.user_dnd_staff? ||
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
        match.schedule_criminal_hearing_housing_subsidy_admin_decision.initialize_decision!
      end
      
      def declined
        match.confirm_shelter_agency_decline_dnd_staff_decision.initialize_decision!
      end
    end
    private_constant :StatusCallbacks
    
    private def validate_client_last_seen_date_present_if_not_working_with_client
      if not_working_with_client_reason.present? && client_last_seen_date.blank?
        errors.add :client_last_seen_date, 'must be filled in if you are no longer working with the client'
      end
    end

    private def decline_reason_blank?
      decline_reason.blank? && not_working_with_client_reason.blank?
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(:client_last_seen_date)
    end
    
    

  end
end

