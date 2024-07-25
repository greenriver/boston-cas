###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Twelve
  class TwelveHsaConfirmMatchSuccess < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteTwelveDeclineReasons
    include MatchDecisions::RouteTwelveCancelReasons

    def to_partial_path
      'match_decisions/twelve/hsa_confirm_match_success'
    end

    validate :cant_accept_if_match_closed
    validate :cant_accept_if_client_has_related_active_match
    validate :cant_accept_if_opportunity_has_related_active_match
    validate :ensure_required_contacts_present_on_accept
    validate :validate_cancel_reason

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending, :expiration_update then "#{Translation.translate('HSA Twelve')} assigned match"
      when :confirmed then "Match success confirmed by #{Translation.translate('HSA Twelve')}"
      when :declined then "Match declined by #{Translation.translate('HSA Twelve')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.twelve_hsa_match_decline_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      "#{Translation.translate('HSA Twelve')} Confirm Match Success"
    end

    def actor_type
      Translation.translate('HSA Twelve')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def statuses
      {
        pending: 'Pending',
        expiration_update: 'Pending',
        confirmed: 'Confirmed',
        declined: 'Declined',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def expires?
      true
    end

    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Twelve::TwelveHsaConfirmMatchSuccess
      end
    end

    def notify_contact_of_action_taken_on_behalf_of(contact:) # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match!(match, contact_actor_type)
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.shelter_agency_contacts)
    end

    def show_client_match_attributes?
      true
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        @decision.next_step.initialize_decision!
      end

      def declined
        match.twelve_hsa_confirm_match_decline_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def expiration_update
      end
    end
    private_constant :StatusCallbacks

    private def save_will_accept?
      saved_status == 'pending' && status == 'confirmed'
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
      missing_contacts << "a #{Translation.translate('CoC Twelve')} Staff Contact" if save_will_accept? && match.dnd_staff_contacts.none?
      missing_contacts << "a #{Translation.translate('Shelter Agency Twelve')} Staff Contact" if save_will_accept? && match.shelter_agency_contacts.none?
      missing_contacts << "a #{Translation.translate('HSA Twelve')} Contact" if save_will_accept? && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end

    private def validate_cancel_reason
      errors.add :administrative_cancel_reason_id, 'please indicate the reason for canceling' if status == 'canceled' && administrative_cancel_reason_id.blank?

      errors.add :administrative_cancel_reason_other_explanation, "must be filled in if choosing 'Other'" if status == 'canceled' && administrative_cancel_reason&.other? && administrative_cancel_reason_other_explanation.blank?
    end

    private def note_present_if_status_declined
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'declined'
    end
  end
end
