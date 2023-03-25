###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Eight
  class EightConfirmAssignManagerDecline < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteEightCancelReasons

    def step_name
      "#{_('DND')} confirms case manager assignment decline"
    end

    def actor_type
      _('DND')
    end

    def contact_actor_type
      nil
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Eight::EightConfirmAssignManagerDecline
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
      when :pending then "#{_('DND')} to confirm #{_('Housing Subsidy Administrator Eight')} decline"
      when :decline_overridden then "#{_('Housing Subsidy Administrator Eight')} Decline overridden by DND.  Match proceeding to #{_('DND')}"
      when :decline_overridden_returned then "#{_('Housing Subsidy Administrator Eight')} overridden by #{_('DND')}.  Match returned to the #{_('Housing Subsidy Administrator Eight')}"
      when :decline_confirmed then "Match rejected by #{_('DND')}"
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
        match.eight_assign_manager_decision.update(status: :skipped)
        match.eight_record_voucher_date_decision.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.eight_assign_manager_decision.initialize_decision!
        @decision.uninitialize_decision!
      end

      def decline_confirmed
        Notifications::Eight::MatchRejected.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::Eight::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def editable?
      super && saved_status !~ /decline_overridden|decline_overridden_returned|decline_confirmed/
    end
  end
end
