###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Fourteen
  class FourteenEligibilityScreeningDecline < Base
    include MatchDecisions::AcceptsDeclineReason

    def to_partial_path
      'match_decisions/fourteen/eligibility_screening_decline'
    end

    def step_name
      "#{Translation.translate('CoC Fourteen')} Eligibility Screening Decline"
    end

    def actor_type
      Translation.translate('CoC Fourteen')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Fourteen::FourteenEligibilityScreeningDecline
      end
    end

    def statuses
      {
        pending: 'Pending',
        decline_overridden: 'Decline Overridden',
        decline_overridden_returned: 'Decline Overridden, Returned',
        decline_confirmed: 'Decline Confirmed',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('CoC Fourteen')} to confirm #{Translation.translate('Housing Search Provider Fourteen')} decline"
      when :decline_overridden then "#{Translation.translate('Housing Search Provider Fourteen')} Decline overridden by #{Translation.translate('CoC Fourteen')}.  Match proceeding to #{Translation.translate('HSA Fourteen')}"
      when :decline_overridden_returned then "#{Translation.translate('Housing Search Provider Fourteen')} overridden by #{Translation.translate('CoC Fourteen')}.  Match returned to the #{Translation.translate('Housing Search Provider Fourteen')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('CoC Fourteen')}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
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
        match.fourteen_eligibility_screening_decision.update(status: :skipped)
        match.fourteen_subsidy_admin_screening_decision.initialize_decision!
      end

      def decline_overridden_returned
        match.fourteen_eligibility_screening_decision.initialize_decision!
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
