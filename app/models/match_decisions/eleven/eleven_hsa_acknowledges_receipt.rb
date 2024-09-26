###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Eleven
  class ElevenHsaAcknowledgesReceipt < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteElevenDeclineReasons
    include MatchDecisions::RouteElevenCancelReasons

    def to_partial_path
      'match_decisions/eleven/hsa_acknowledges_receipt'
    end

    validate :cant_accept_if_match_closed
    validate :cant_accept_if_client_has_related_active_match
    validate :cant_accept_if_opportunity_has_related_active_match
    validate :ensure_required_contacts_present_on_accept
    validate :validate_cancel_reason

    def label_for_status status
      case status.to_sym
      when :pending, :expiration_update then "New Match Awaiting Acknowledgment by #{Translation.translate('HSA Eleven')}"
      when :acknowledged then "Match acknowledged by #{Translation.translate('HSA Eleven')}.  In review"
      when :canceled then canceled_status_label
      end
    end

    def started?
      status&.to_sym == :acknowledged
    end

    def step_name
      "New Match for #{Translation.translate('HSA Eleven')}"
    end

    def actor_type
      Translation.translate('HSA Eleven')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def statuses
      {
        pending: 'Pending',
        expiration_update: 'Pending',
        acknowledged: 'Acknowledged',
        declined: 'Declined',
        canceled: 'Canceled',
        destroy: 'Destroy',
      }
    end

    def expires?
      true
    end

    def editable?
      super && saved_status !~ /acknowledged/
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: :pending
      send_notifications_for_step if send_notifications
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.send(contact_actor_type))
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Eleven::MatchInitiationForHsa
        m << Notifications::Eleven::MatchInitiationForShelterAgency
        m << Notifications::Eleven::MatchInitiationForSsp
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def acknowledged
        @decision.next_step.initialize_decision!
        return unless !match.client.non_hmis? && match.client.remote_id.present? && Warehouse::Base.enabled?

        Warehouse::Client.find_by(id: match.client.remote_id)&.queue_history_pdf_generation
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def expiration_update
      end
    end
    private_constant :StatusCallbacks

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :shelter_expiration,
      )
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'acknowledged'
    end

    def cant_accept_if_match_closed
      return unless save_will_accept? && match.closed

      errors.add :status, 'This match has already been closed.'
    end

    def cant_accept_if_client_has_related_active_match
      return unless save_will_accept? && match.client_related_matches.active.on_route(match_route).exists? && ! match_route.allow_multiple_active_matches

      errors.add :status, 'There is already another active match for this client'
    end

    def cant_accept_if_opportunity_has_related_active_match
      return unless save_will_accept? && match.opportunity_related_matches.active.any? && ! match_route.allow_multiple_active_matches

      errors.add :status, 'There is already another active match for this opportunity'
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('CoC Eleven')} Staff Contact" if save_will_accept? && match.dnd_staff_contacts.none?
      missing_contacts << "a #{Translation.translate('Housing Subsidy Administrator Eleven')} Contact" if save_will_accept? && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end

    private def validate_cancel_reason
      errors.add :administrative_cancel_reason_id, 'please indicate the reason for canceling' if status == 'canceled' && administrative_cancel_reason_id.blank?

      errors.add :administrative_cancel_reason_other_explanation, "must be filled in if choosing 'Other'" if status == 'canceled' && administrative_cancel_reason&.other? && administrative_cancel_reason_other_explanation.blank?
    end
  end
end
