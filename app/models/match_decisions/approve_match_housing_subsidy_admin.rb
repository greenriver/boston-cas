module MatchDecisions
  class ApproveMatchHousingSubsidyAdmin < Base
    
    include MatchDecisions::AcceptsDeclineReason

    # validate :note_present_if_status_declined
    
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then 'Housing Subsidy Administrator reviewing match'
      when :accepted then 'Match accepted by Housing Subsidy Administrator'
      when :declined then "Match declined by Housing Subsidy Administrator.  Reason: #{decline_reason_name}"
      end
    end

    def step_name
      'Housing Subsidy Administrator Reviews Match'
    end

    def actor_type
      'HSA'
    end
    
    def statuses
      {pending: 'Pending', accepted: 'Accepted', declined: 'Declined'}
    end
    
    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def initialize_decision!
      update status: 'pending'
    end
    
    def accessible_by? contact
      contact.user_admin? ||
      contact.user_dnd_staff? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end

    private def decline_reason_scope
      MatchDecisionReasons::HousingSubsidyAdminDecline.all
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        match.record_client_housed_date_shelter_agency_decision.initialize_decision!
        Notifications::HousingSubsidyAdminDecisionClient.create_for_match! match
        Notifications::HousingSubsidyAdminAcceptedMatchDndStaff.create_for_match! match
      end

      def declined
        Notifications::HousingSubsidyAdminDecisionClient.create_for_match! match
        Notifications::HousingSubsidyAdminDeclinedMatchShelterAgency.create_for_match! match
        match.confirm_housing_subsidy_admin_decline_dnd_staff_decision.initialize_decision!
      end
    end
    private_constant :StatusCallbacks

    private def note_present_if_status_declined
      if note.blank? && status == 'declined'
        errors.add :note, 'Please note why the match is declined.'
      end
    end
    
  end
  
end

