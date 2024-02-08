###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::ProviderOnly
  class HsaAcceptsClient < ::MatchDecisions::Base
    def to_partial_path
      'match_decisions/hsa_accepts_client'
    end
    include MatchDecisions::AcceptsDeclineReason

    attr_accessor :building_id
    attr_accessor :unit_id

    # validate :note_present_if_status_declined

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending, :expiration_update then "#{Translation.translate('Housing Subsidy Administrator')} reviewing match"
      when :accepted then "Match accepted by #{Translation.translate('Housing Subsidy Administrator')}"
      when :declined then "Match declined by #{Translation.translate('Housing Subsidy Administrator')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.confirm_hsa_accepts_client_decline_dnd_staff_decision.status == 'decline_overridden'
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
        expiration_update: 'Pending',
        accepted: 'Accepted',
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
        m << Notifications::ProviderOnly::HsaAcceptsClient
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end

    def show_client_match_attributes?
      true
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        Notifications::ProviderOnly::HsaAcceptsClientSspNotification.create_for_match! match
        match.succeeded!
      end

      def declined
        match.confirm_hsa_accepts_client_decline_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def expiration_update
      end
    end
    private_constant :StatusCallbacks

    def step_decline_reasons(_contact)
      [
        'Household could not be located',
        'Ineligible for Housing Program',
        'Client refused offer',
        'Health and Safety',
        'Other',
      ]
    end

    def step_cancel_reasons
      [
        'Vacancy should not have been entered',
        'Vacancy filled by other client',
        'Other',
      ]
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :building_id,
        :unit_id,
        :shelter_expiration,
      )
    end

    private def note_present_if_status_declined
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'declined'
    end
  end
end
