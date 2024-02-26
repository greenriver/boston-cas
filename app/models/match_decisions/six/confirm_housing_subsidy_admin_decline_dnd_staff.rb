###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Six
  class ConfirmHousingSubsidyAdminDeclineDndStaff < ::MatchDecisions::Base
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
      when :pending then "#{Translation.translate('CoC Six')} to confirm #{Translation.translate('Housing Subsidy Administrator Six')} decline"
      when :decline_overridden then "#{Translation.translate('Housing Subsidy Administrator Six')} Decline overridden by #{Translation.translate('CoC Six')}.  Match proceeding to #{Translation.translate('Housing Subsidy Administrator Six')}"
      when :decline_overridden_returned then "#{Translation.translate('Housing Subsidy Administrator Six')} Decline overridden by #{Translation.translate('CoC Six')}.  Match returned to #{Translation.translate('Housing Subsidy Administrator Six')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('CoC Six')}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{Translation.translate('CoC Six')} Reviews Match Declined by #{Translation.translate('HSA Six')}"
    end

    def actor_type
      Translation.translate('CoC Six')
    end

    def contact_actor_type
      nil
    end

    def editable?
      super && saved_status !~ /decline_overridden|decline_overridden_returned|decline_confirmed/
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Six::ConfirmHsaDeclineDndStaff
        m << Notifications::HousingSubsidyAdminDeclinedMatchShelterAgency
      end
    end

    def accessible_by? contact
      contact&.user_can_reject_matches? || contact&.user_can_approve_matches?
    end

    def to_param
      :six_confirm_housing_subsidy_admin_decline_dnd_staff
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.six_confirm_match_success_dnd_staff_decision.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.six_approve_match_housing_subsidy_admin_decision.initialize_decision!
        @decision.uninitialize_decision!
      end

      def decline_confirmed
        Notifications::Six::MatchRejected.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::Six::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
