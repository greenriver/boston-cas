###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Ten
  class TenAgencyConfirmMatchSuccessDecline < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteTenCancelReasons

    def step_name
      "#{_('DND')} Confirms Match Success Decline"
    end

    def actor_type
      _('DND')
    end

    def contact_actor_type
      nil
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Ten::TenAgencyConfirmMatchSuccessDecline
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
      when :pending then "#{_('DND')} to confirm #{_('Shelter Agency Ten')} decline"
      when :decline_overridden then "#{_('Shelter Agency Ten')} Decline overridden by #{_('DND')}.  Match proceeding to #{_('DND')}"
      when :decline_overridden_returned then "#{_('Shelter Agency Ten')} overridden by #{_('DND')}.  Match returned to the #{_('Shelter Agency Ten')}"
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
        match.ten_agency_confirm_match_success_decision.update(status: :skipped)
        match.ten_confirm_match_success_dnd_staff_decision.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.ten_agency_confirm_match_success_decision.initialize_decision!
        @decision.uninitialize_decision!
      end

      def decline_confirmed
        Notifications::MatchRejected.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def editable?
      super && saved_status !~ /decline_overridden|decline_overridden_returned|decline_confirmed/
    end
  end
end