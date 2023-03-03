###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Five
  class FiveApplicationSubmission < Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::DefaultShelterAgencyDeclineReasons

    validate :application_date_present_if_status_complete

    def step_name
      _('Submit Client Application')
    end

    def expires?
      true
    end

    def contact_actor_type
      :shelter_agency_contacts
    end

    def show_client_match_attributes?
      true
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Five::ApplicationSubmission
      end
    end

    def permitted_params
      super + [:application_date, :prevent_matching_until]
    end

    def statuses
      {
        pending: 'Pending',
        expiration_update: 'Pending',
        accepted: 'Accept',
        declined: 'Decline',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then 'Match Awaiting Application Submission'
      when :expiration_update then 'Match Awaiting Application Submission'
      when :accepted then "Client Application Submitted by #{actor_type}"
      when :declined then "Match Declined by #{actor_type}.  Reason: #{decline_reason_name}"
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

      def expiration_update
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        match.rejected!
      end

      def canceled
        Notifications::Five::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def editable?
      super && saved_status !~ /accepted|declined/
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    private def application_date_present_if_status_complete
      errors.add :application_date, 'must be filled in' if status == 'completed' && application_date.blank?
    end
  end
end
