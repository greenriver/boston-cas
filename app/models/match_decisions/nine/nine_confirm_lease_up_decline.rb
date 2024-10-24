###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class NineConfirmLeaseUpDecline < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteNineDeclineReasons
    include MatchDecisions::RouteNineCancelReasons

    def step_name
      "#{Translation.translate('DND')} confirms #{Translation.translate('Move In')} failure"
    end

    def actor_type
      Translation.translate('DND')
    end

    def contact_actor_type
      nil
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Nine::NineConfirmLeaseUpDecline
      end
    end

    def statuses
      {
        pending: 'Pending',
        decline_overridden: 'Decline Overridden',
        decline_overridden_returned: 'Decline Overridden, Returned',
        decline_confirmed: 'Decline Confirmed',
        canceled: 'Canceled',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('DND')} to confirm #{Translation.translate('HSA Nine')} decline"
      when :decline_overridden then "#{Translation.translate('HSA Nine')} Decline overridden by #{Translation.translate('DND')}.  Match proceeding to #{Translation.translate('Stabilization Service Provider Nine')}"
      when :decline_overridden_returned then "#{Translation.translate('HSA Nine')} overridden by #{Translation.translate('DND')}.  Match returned to the #{Translation.translate('HSA Nine')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('DND')}"
      when :canceled then canceled_status_label
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.nine_lease_up_decision.update(status: :skipped)
        match.nine_confirm_match_success_decision.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.nine_lease_up_decision.initialize_decision!
        @decision.uninitialize_decision!
      end

      def decline_confirmed
        Notifications::Nine::MatchRejected.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::Nine::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def step_decline_reasons(_contact)
      [
        'Immigration status',
        'Ineligible for Housing Program',
        'Self-resolved',
        'Household did not respond after initial acceptance of match',
        'Client refused offer',
        'Client needs higher level of care',
        'Unable to reach client after multiple attempts',
        'Other',
      ].freeze
    end
  end
end
