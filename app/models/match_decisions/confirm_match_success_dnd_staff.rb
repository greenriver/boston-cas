###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  class ConfirmMatchSuccessDndStaff < Base
    # validate :note_present_if_status_rejected

    def statuses
      {
        pending: 'Pending',
        confirmed: 'Confirmed',
        rejected: 'Rejected',
        canceled: 'Canceled', # added to support cancellations caused by other match success
        back: 'Pending',
      }
    end

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('DND')} to confirm match success"
      when :confirmed then "#{Translation.translate('DND')} confirms match success"
      when :rejected then "Match rejected by #{Translation.translate('DND')}"
      when :canceled then 'Match canceled'
      when :back then backup_status_label
      end
    end

    def step_name
      Translation.translate('Confirm Match Success')
    end

    def actor_type
      Translation.translate('DND')
    end

    def contact_actor_type
      nil
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      Notifications::ConfirmMatchSuccessDndStaff.create_for_match! match
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        # m << Notifications::RecordClientHousedDateHousingSubsidyAdministrator
        m << Notifications::MoveInDateSet # Sent to both HSA and Shelter Agency
        m << Notifications::ConfirmMatchSuccessDndStaff
      end
    end

    def accessible_by? contact
      contact.user_can_reject_matches? || contact.user_can_approve_matches?
    end

    private def note_present_if_status_rejected
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'rejected'
    end

    def show_client_match_attributes?
      true
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        Notifications::MatchSuccessConfirmedDevelopmentOfficer.create_for_match! match
        match.succeeded!(user: user)
      end

      def rejected
        match.rejected!
      end
    end
    private_constant :StatusCallbacks
  end
end
