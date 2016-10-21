module MatchDecisions
  class ConfirmHousingSubsidyAdminDeclineDndStaff < Base
    
    def statuses
      {pending: 'Pending', decline_overridden: 'Decline Overridden', decline_overridden_returned: 'Decline Overridden, Returned', decline_confirmed: 'Decline Confirmed'}
    end
    
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then 'DND to confirm match success'
      when :decline_overridden then 'Housing Subsidy Administrator Decline overridden by DND.  Match proceeding to Housing Subsidy Administrator'
      when :decline_overridden_returned then 'Housing Subsidy Administrator Decline overridden by DND.  Match returned to Housing Subsidy Administrator'
      when :decline_confirmed then 'Match rejected by DND'
      end
    end

    def step_name
      'DND Reviews Match Declined by HSA'
    end

    def actor_type
      'DND'
    end

    def contact_actor_type
      nil
    end
    
    def editable?
      super && saved_status !~ /decline_overridden|decline_overridden_returned|decline_confirmed/
    end

    def initialize_decision!
      update status: 'pending'
      Notifications::ConfirmHousingSubsidyAdminDeclineDndStaff.create_for_match! match
    end

    def uninitialize_decision!
      update status: nil
    end
    
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::ConfirmHousingSubsidyAdminDeclineDndStaff
      end
    end

    def accessible_by? contact
      contact.user_admin? ||
      contact.user_dnd_staff?
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.record_client_housed_date_housing_subsidy_administrator_decision.initialize_decision!
        Notifications::HousingSubsidyAdminDecisionClient.create_for_match! match
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.approve_match_housing_subsidy_admin_decision.initialize_decision!
        match.confirm_housing_subsidy_admin_decline_dnd_staff_decision.uninitialize_decision!
        # Send the notifications again
        Notifications::CriminalHearingScheduledClient.create_for_match! match
        Notifications::CriminalHearingScheduledDndStaff.create_for_match! match
        Notifications::CriminalHearingScheduledShelterAgency.create_for_match! match
      end
      
      def decline_confirmed
        match.rejected!
        # TODO maybe rerun the matching engine for that vancancy and client
      end
    end
    private_constant :StatusCallbacks
    
  end
  
end

