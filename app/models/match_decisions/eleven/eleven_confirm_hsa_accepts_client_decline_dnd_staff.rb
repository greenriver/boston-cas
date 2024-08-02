###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Eleven
  class ElevenConfirmHsaAcceptsClientDeclineDndStaff < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteElevenDeclineReasons
    include MatchDecisions::RouteElevenCancelReasons

    def to_partial_path
      'match_decisions/eleven/confirm_hsa_accepts_client_decline_dnd_staff'
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

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('CoC Eleven')} to confirm #{Translation.translate('Housing Subsidy Administrator Eleven')} decline"
      when :decline_overridden then "#{Translation.translate('Housing Subsidy Administrator Eleven')} decline overridden by #{Translation.translate('CoC Eleven')}.  Match successful"
      when :decline_overridden_returned then "#{Translation.translate('Housing Subsidy Administrator Eleven')} decline overridden by #{Translation.translate('CoC Eleven')}.  Match returned to #{Translation.translate('Housing Subsidy Administrator Eleven')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('CoC Eleven')}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{Translation.translate('CoC Eleven')} Reviews Match Declined by #{Translation.translate('HSA Eleven')}"
    end

    def actor_type
      Translation.translate('CoC Eleven')
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
        m << Notifications::Eleven::ConfirmHsaDeclineDndStaff
        m << Notifications::Eleven::HsaDecisionClient
        m << Notifications::Eleven::HsaDecisionSsp
        m << Notifications::Eleven::HsaDecisionHsp
        m << Notifications::Eleven::HsaDecisionShelterAgency
      end
    end

    def accessible_by? contact
      contact.user_can_reject_matches? ||
      contact.user_can_approve_matches?
    end

    def show_client_match_attributes?
      true
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.succeeded!(user: user)
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.eleven_hsa_accepts_client_decision.initialize_decision!
        @decision.uninitialize_decision!(send_notifications: false)
      end

      def decline_confirmed
        match.rejected!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
