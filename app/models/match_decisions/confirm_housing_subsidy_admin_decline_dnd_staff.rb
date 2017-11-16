module MatchDecisions
  class ConfirmHousingSubsidyAdminDeclineDndStaff < Base
    
    def statuses
      {
        pending: 'Pending', 
        decline_overridden: 'Decline Overridden', 
        decline_overridden_returned: 'Decline Overridden, Returned',
        decline_confirmed: 'Decline Confirmed',
        canceled: 'Canceled',
       }
    end
    
    def label
      label_for_status status
    end
    
    def label_for_status status
      case status.to_sym
      when :pending then "#{_('DND')} to confirm match success"
      when :decline_overridden then "#{_('Housing Subsidy Administrator')} Decline overridden by #{_('DND')}.  Match proceeding to #{_('Housing Subsidy Administrator')}"
      when :decline_overridden_returned then "#{_('Housing Subsidy Administrator')} Decline overridden by #{_('DND')}.  Match returned to #{_('Housing Subsidy Administrator')}"
      when :decline_confirmed then "Match rejected by #{_('DND')}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{_('DND')} Reviews Match Declined by #{_('HSA')}"
    end

    def actor_type
      _('DND')
    end

    def contact_actor_type
      nil
    end
    
    def editable?
      super && saved_status !~ /decline_overridden|decline_overridden_returned|decline_confirmed/
    end

    def permitted_params
      super
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
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end
    
    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.record_client_housed_date_housing_subsidy_administrator_decision.initialize_decision!
        Notifications::HousingSubsidyAdminDecisionClient.create_for_match! match
        Notifications::HousingSubsidyAdminDecisionSsp.create_for_match! match
        Notifications::HousingSubsidyAdminDecisionHsp.create_for_match! match
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.approve_match_housing_subsidy_admin_decision.initialize_decision!
        match.confirm_housing_subsidy_admin_decline_dnd_staff_decision.uninitialize_decision!
        # Send the notifications again
        Notifications::CriminalHearingScheduledClient.create_for_match! match
        Notifications::CriminalHearingScheduledDndStaff.create_for_match! match
        Notifications::CriminalHearingScheduledShelterAgency.create_for_match! match
        Notifications::CriminalHearingScheduledSsp.create_for_match! match
        Notifications::CriminalHearingScheduledHsp.create_for_match! match
        Notifications::ScheduleCriminalHearingHousingSubsidyAdmin.create_for_match! match
      end
      
      def decline_confirmed
        match.rejected!
        # TODO maybe rerun the matching engine for that vancancy and client
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
    
  end
  
end

