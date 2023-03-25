###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::ProviderOnly
  class ConfirmHsaAcceptsClientDeclineDndStaff < ::MatchDecisions::Base
    def to_partial_path
      'match_decisions/confirm_hsa_accepts_client_decline_dnd_staff'
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
      when :pending then "#{_('DND')} to confirm #{_('Housing Subsidy Administrator')} decline"
      when :decline_overridden then "#{_('Housing Subsidy Administrator')} decline overridden by #{_('DND')}.  Match successful"
      when :decline_overridden_returned then "#{_('Housing Subsidy Administrator')} decline overridden by #{_('DND')}.  Match returned to #{_('Housing Subsidy Administrator')}"
      when :decline_confirmed then "Match rejected by #{_('DND')}"
      when :canceled then canceled_status_label
      end
    end

    def step_name
      "#{_('DND')} Reviews Match Declined by #{_('HSA')}"
    end

    def actor_type
      _('DND')
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
        m << Notifications::ProviderOnly::ConfirmHsaDeclineDndStaff
        m << Notifications::ProviderOnly::HsaDecisionClient
        m << Notifications::ProviderOnly::HsaDecisionSsp
        m << Notifications::ProviderOnly::HsaDecisionHsp
        m << Notifications::ProviderOnly::HsaDecisionShelterAgency
      end
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    def show_client_match_attributes?
      true
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def decline_overridden
        match.succeeded!
      end

      def decline_overridden_returned
        # Re-initialize the previous decision
        match.hsa_accepts_client_decision.initialize_decision!
        @decision.uninitialize_decision!(send_notifications: false)
      end

      def decline_confirmed
        match.rejected!
        # TODO maybe rerun the matching engine for that vacancy and client
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end

  def step_cancel_reasons
    [
      'Vacancy should not have been entered',
      'Vacancy filled by other client',
      'Other',
    ]
  end
end
