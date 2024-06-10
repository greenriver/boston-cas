###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Six
  class ConfirmMatchSuccessDndStaff < ::MatchDecisions::Base
    # validate :note_present_if_status_rejected
    def to_partial_path
      'match_decisions/six_confirm_match_success_dnd_staff'
    end

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
      when :pending then "#{Translation.translate('CoC Six')} to confirm match success"
      when :confirmed then "#{Translation.translate('CoC Six')} confirms match success"
      when :rejected then "Match rejected by #{Translation.translate('CoC Six')}"
      when :canceled then 'Match canceled'
      when :back then backup_status_label
      end
    end

    def started?
      status&.to_sym == :confirmed
    end

    def step_name
      Translation.translate('Confirm Match Success Six')
    end

    def actor_type
      Translation.translate('CoC Six')
    end

    def contact_actor_type
      nil
    end

    def editable?
      super && status !~ /confirmed|rejected/
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Six::ConfirmMatchSuccessDndStaff
        m << Notifications::Six::ConfirmMatchSuccessShelterAgency
      end
    end

    def accessible_by? contact
      contact&.user_can_reject_matches? || contact&.user_can_approve_matches?
    end

    def to_param
      :six_confirm_match_success_dnd_staff
    end

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :building_id,
        :unit_id,
        :client_move_in_date,
        :external_software_used,
        :address,
      )
    end

    private def note_present_if_status_rejected
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status == 'rejected'
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        Notifications::MatchSuccessConfirmed.create_for_match! match
        match.succeeded!(user: @dependencies.try(:[], :user))
      end

      def rejected
        Notifications::MatchRejected.create_for_match! match
        match.rejected!
      end
    end
    private_constant :StatusCallbacks
  end
end
