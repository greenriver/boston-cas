###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Ten
  class TenAgencyConfirmMatchSuccess < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteTenDeclineReasons
    include MatchDecisions::RouteTenCancelReasons

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending, :expiration_update then "#{_('Shelter Agency Ten')} assigned match"
      when :confirmed then "Match success confirmed by #{_('Shelter Agency Ten')}"
      when :declined then "Match declined by #{_('Shelter Agency Ten')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.ten_agency_match_success_decline_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      _('Confirm Match Success')
    end

    def actor_type
      _('Shelter Agency Ten')
    end

    def contact_actor_type
      :shelter_agency_contacts
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
        m << Notifications::Ten::TenAgencyConfirmMatchSuccess
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
        match.ten_agency_confirm_match_success_decline_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def expiration_update
      end
    end
    private_constant :StatusCallbacks

    private def note_present_if_status_declined
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'declined'
    end
  end
end
