###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Seven
  class ApproveMatchHousingSubsidyAdmin < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::DefaultHsaDeclineReasons

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Housing Subsidy Administrator')} reviewing match"
      when :accepted then "Match accepted by #{Translation.translate('Housing Subsidy Administrator')}"
      when :declined then "Match declined by #{Translation.translate('Housing Subsidy Administrator')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.confirm_housing_subsidy_admin_decline_dnd_staff_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      Translation.translate('HSA Complete Match')
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
        back: 'Pending',
      }
    end

    def stallable?
      true
    end

    def stalled_contact_types
      @stalled_contact_types ||= [
        :shelter_agency_contacts,
        :housing_subsidy_admin_contacts,
      ]
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      inform_client(:new_match) if send_notifications
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Seven::ApproveMatchHousingSubsidyAdminFromDnd
        m << Notifications::Seven::MatchInProgressShelterAgency
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.housing_subsidy_admin_contacts)
    end

    def to_param
      :seven_approve_match_housing_subsidy_admin
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        Notifications::MatchDeclined.create_for_match! match
        match.seven_confirm_housing_subsidy_admin_decline_dnd_staff_decision.initialize_decision!
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
  end
end
