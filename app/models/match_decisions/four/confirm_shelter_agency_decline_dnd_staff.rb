###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Four
  class ConfirmShelterAgencyDeclineDndStaff < ::MatchDecisions::Base
    include MatchDecisions::RouteFourCancelReasons

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
      when :pending then "#{Translation.translate('DND')} to confirm #{Translation.translate('Shelter Agency')} decline"
      when :decline_overridden then "#{Translation.translate('Shelter Agency')} Decline overridden by DND.  Match proceeding to #{Translation.translate('Housing Subsidy Administrator')}"
      when :decline_overridden_returned then "#{Translation.translate('Shelter Agency')} overridden by #{Translation.translate('DND')}.  Match returned to the #{Translation.translate('Shelter Agency')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('DND')}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{Translation.translate('DND')} Reviews Match Declined by #{Translation.translate('Shelter Agency')}"
    end

    def actor_type
      Translation.translate('DND')
    end

    def contact_actor_type
      nil
    end

    def permitted_params
      super + [:prevent_matching_until]
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Four::ConfirmShelterAgencyDeclineDndStaff
      end
    end

    def accessible_by? contact
      contact&.user_can_reject_matches? || contact&.user_can_approve_matches?
    end

    def to_param
      :four_confirm_shelter_agency_decline_dnd_staff
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.four_match_recommendation_hsa_decision.initialize_decision!
        # TODO notify shelter agency of decline override
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.four_match_recommendation_shelter_agency_decision.initialize_decision!
        @decision.uninitialize_decision!
      end

      def decline_confirmed
        Notifications::Four::MatchRejected.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::Four::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
