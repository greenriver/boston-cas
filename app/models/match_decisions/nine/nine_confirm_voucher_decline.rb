###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class NineConfirmVoucherDecline < ::MatchDecisions::Base
    include MatchDecisions::RouteEightCancelReasons

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
      when :pending then "#{Translation.translate('DND')} to confirm #{Translation.translate('Housing Subsidy Administrator Nine')} decline"
      when :decline_overridden then "#{Translation.translate('Housing Subsidy Administrator Nine')} Decline overridden by #{Translation.translate('DND')}.  Match proceeding to #{Translation.translate('DND')}"
      when :decline_overridden_returned then "#{Translation.translate('Housing Subsidy Administrator Nine')} Decline overridden by #{Translation.translate('DND')}.  Match returned to #{Translation.translate('Housing Subsidy Administrator Nine')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('DND')}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{Translation.translate('DND')} Reviews Voucher Declined by #{Translation.translate('HSA Nine')}"
    end

    def actor_type
      Translation.translate('DND')
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
        m << Notifications::Nine::NineConfirmVoucherDecline
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.nine_record_voucher_date_decision.update(status: :skipped)
        match.nine_assign_case_contact_decision.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.nine_record_voucher_date_decision.initialize_decision!
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
  end
end
