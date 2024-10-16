###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::HomelessSetAside
  class SetAsidesHsaAcceptsClient < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::DefaultSetAsidesDeclineReasons

    # validate :note_present_if_status_declined
    validate :ensure_required_contacts_present_on_accept

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Housing Subsidy Administrator')} reviewing match"
      when :accepted then "Match accepted by #{Translation.translate('Housing Subsidy Administrator')}"
      when :declined then "Match declined by #{Translation.translate('Housing Subsidy Administrator')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.set_asides_confirm_hsa_accepts_client_decline_dnd_staff_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      Translation.translate('Client Agrees to Match')
    end

    def actor_type
      Translation.translate('HSA')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        declined: 'Declined',
        canceled: 'Canceled',
        destroy: 'Destroy',
      }
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::HomelessSetAside::HsaAcceptsClient
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!

        Notifications::HomelessSetAside::HsaAcceptsClientSspNotification.create_for_match! match
      end

      def declined
        # FIXME: next time we use the set-aside route, we need a new decision here
        match.set_asides_confirm_hsa_accepts_client_decline_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private def note_present_if_status_declined
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'declined'
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('DND')} Staff Contact" if save_will_accept? && match.dnd_staff_contacts.none?

      missing_contacts << "a #{Translation.translate('Housing Subsidy Administrator')} Contact" if save_will_accept? && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end
  end
end
