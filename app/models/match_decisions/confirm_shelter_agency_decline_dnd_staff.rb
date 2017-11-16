module MatchDecisions
  class ConfirmShelterAgencyDeclineDndStaff < Base
    
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
      when :decline_overridden then "#{_('Shelter Agency')} Decline overridden by DND.  Match proceeding to #{_('Housing Subsidy Administrator')}"
      when :decline_overridden_returned then "#{_('Shelter Agency')} overridden by #{_('DND')}.  Match returned to the #{_('Shelter Agency')}"
      when :decline_confirmed then "Match rejected by #{_('DND')}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{_('DND')} Reviews Match Declined by #{_('Shelter Agency')}"
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
      super + [:prevent_matching_until]
    end

    def initialize_decision!
      update status: 'pending'
      Notifications::ConfirmShelterAgencyDeclineDndStaff.create_for_match! match
    end

    def uninitialize_decision!
      update status: nil
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::ConfirmShelterAgencyDeclineDndStaff
      end
    end
    
    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.schedule_criminal_hearing_housing_subsidy_admin_decision.initialize_decision!
        # TODO notify shelter agency of decline override
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.match_recommendation_shelter_agency_decision.initialize_decision!
        match.confirm_shelter_agency_decline_dnd_staff_decision.uninitialize_decision!
        # Send the notifications again
        Notifications::MatchRecommendationHousingSubsidyAdmin.create_for_match! match
        Notifications::MatchRecommendationClient.create_for_match! match
        Notifications::MatchRecommendationSsp.create_for_match! match
        Notifications::MatchRecommendationHsp.create_for_match! match
      end
      
      def decline_confirmed
        Notifications::ShelterAgencyDeclineAccepted.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
    
  end
  
end

