###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Eleven
  class ElevenConfirmMatchSuccessDndStaff < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteElevenDeclineReasons
    include MatchDecisions::RouteElevenCancelReasons
    # validate :note_present_if_status_rejected

    def to_partial_path
      'match_decisions/eleven/confirm_match_success_dnd_staff'
    end

    def statuses
      {
        pending: 'Pending',
        confirmed: 'Confirmed',
        rejected: 'Rejected', # Not currently used
        declined: 'Declined',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('CoC Eleven')} to confirm match success"
      when :confirmed then "#{Translation.translate('CoC Eleven')} confirms match success"
      when :rejected, :declined then "Match rejected by #{Translation.translate('CoC Eleven')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def started?
      status&.to_sym == :confirmed
    end

    def step_name
      "#{Translation.translate('CoC Eleven')} Review Match Success"
    end

    def actor_type
      Translation.translate('CoC Eleven')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Eleven::ConfirmMatchSuccessDndStaff
      end
    end

    def accessible_by? contact
      contact&.user_can_reject_matches? || contact&.user_can_approve_matches?
    end

    def to_param
      :eleven_confirm_match_success_dnd_staff
    end

    private def note_present_if_status_rejected
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'rejected'
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        Notifications::MatchSuccessConfirmed.create_for_match! match
        match.succeeded!(user: user)
      end

      def declined
        Notifications::MatchDeclined.create_for_match! match
        match.rejected!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def rejected
        Notifications::MatchRejected.create_for_match! match
        match.rejected!
      end
    end
    private_constant :StatusCallbacks
  end
end
