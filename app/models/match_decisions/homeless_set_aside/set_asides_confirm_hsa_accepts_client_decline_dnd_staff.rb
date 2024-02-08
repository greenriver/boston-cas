###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::HomelessSetAside
  class SetAsidesConfirmHsaAcceptsClientDeclineDndStaff < ::MatchDecisions::Base
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

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('DND')} to confirm #{Translation.translate('Housing Subsidy Administrator')} decline"
      when :decline_overridden then "#{Translation.translate('Housing Subsidy Administrator')} Decline overridden by #{Translation.translate('DND')}.  Match successful"
      when :decline_overridden_returned then "#{Translation.translate('Housing Subsidy Administrator')} Decline overridden by #{Translation.translate('DND')}.  Match returned to #{Translation.translate('Housing Subsidy Administrator')}"
      when :decline_confirmed then "Match rejected by #{Translation.translate('DND')}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def step_name
      "#{Translation.translate('DND')} Reviews Match Declined by #{Translation.translate('HSA')}"
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
        m << Notifications::HomelessSetAside::ConfirmHsaDeclineDndStaff
        m << Notifications::HomelessSetAside::HsaDecisionClient
        m << Notifications::HomelessSetAside::HsaDecisionSsp
        m << Notifications::HomelessSetAside::HsaDecisionHsp
        m << Notifications::HomelessSetAside::HsaDecisionShelterAgency
      end
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.succeeded!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.set_asides_hsa_accepts_client_decision.initialize_decision!
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
