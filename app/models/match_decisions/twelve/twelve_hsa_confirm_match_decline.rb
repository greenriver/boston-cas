###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Twelve
  class TwelveHsaConfirmMatchDecline < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteTwelveDeclineReasons
    include MatchDecisions::RouteTwelveCancelReasons

    def to_partial_path
      'match_decisions/twelve/hsa_confirm_match_decline'
    end

    def step_name
      "#{Translation.translate('CoC Twelve')} Match Decline Review"
    end

    def actor_type
      Translation.translate('CoC Twelve')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Twelve::TwelveHsaConfirmMatchDecline
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
      when :pending then "#{Translation.translate('CoC Twelve')} to confirm #{Translation.translate('HSA Ten')} decline"
      when :decline_overridden then "#{Translation.translate('HSA Twelve')} Decline overridden by #{Translation.translate('CoC Twelve')}.  Match proceeding to #{Translation.translate('CoC Twelve')}"
      when :decline_overridden_returned then "#{Translation.translate('HSA Twelve')} overridden by #{Translation.translate('CoC Twelve')}.  Match returned to the #{Translation.translate('HSA Twelve')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('CoC Twelve')}"
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
        match.twelve_hsa_confirm_match_success_decision.update(status: :skipped)
        match.twelve_confirm_match_success_dnd_staff_decision.initialize_decision!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.twelve_hsa_confirm_match_success_decision.initialize_decision!
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
