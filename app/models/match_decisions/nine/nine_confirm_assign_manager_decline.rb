###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class NineConfirmAssignManagerDecline < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteNineDeclineReasons
    include MatchDecisions::RouteNineCancelReasons

    def step_name
      "#{Translation.translate('DND')} confirms case manager assignment decline"
    end

    def actor_type
      Translation.translate('DND')
    end

    def contact_actor_type
      nil
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Nine::NineConfirmAssignManagerDecline
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
      when :pending then "#{Translation.translate('DND')} to confirm #{Translation.translate('Stabilization Service Provider Nine')} decline"
      when :decline_overridden then "#{Translation.translate('Stabilization Service Provider Nine')} Decline overridden by DND.  Match proceeding to #{Translation.translate('DND')}"
      when :decline_overridden_returned then "#{Translation.translate('Stabilization Service Provider Nine')} overridden by #{Translation.translate('DND')}.  Match returned to the #{Translation.translate('Stabilization Service Provider Nine')}"
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
        match.nine_assign_manager_decision.update(status: :skipped)
        match.nine_lease_up_decision.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.nine_assign_manager_decision.initialize_decision!
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

    def editable?
      super && saved_status !~ /decline_overridden|decline_overridden_returned|decline_confirmed/
    end
  end
end
