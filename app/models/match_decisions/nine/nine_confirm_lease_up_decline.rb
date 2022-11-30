###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class NineConfirmLeaseUpDecline < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    def step_name
      "#{_('DND')} confirms #{_('Move In')} failure"
    end

    def actor_type
      _('DND')
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
      when :pending then "#{_('DND')} to confirm #{_('HSA Nine')} decline"
      when :decline_overridden then "#{_('HSA Nine')} Decline overridden by DND.  Match proceeding to #{_('DND')}"
      when :decline_overridden_returned then "#{_('HSA Nine')} overridden by #{_('DND')}.  Match returned to the #{_('HSA Nine')}"
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
        match.nine_lease_up_decision.update(status: :skipped)
        match.nine_assign_case_contact.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.nine_lease_up_decision.initialize_decision!
        @decision.uninitialize_decision!
      end

      def decline_confirmed
        Notifications::Nine::NineLeaseUpDeclineAccepted.create_for_match! match
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

    private def decline_reason_scope(_contact)
      MatchDecisionReasons::NineCaseContactAssignsManagerDecline.active
    end
  end
end
