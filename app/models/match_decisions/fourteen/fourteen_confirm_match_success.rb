###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Fourteen
  class FourteenConfirmMatchSuccess < Base
    validate :client_move_in_date_present_if_confirmed

    def statuses
      {
        pending: 'Pending',
        confirmed: 'Confirmed',
        rejected: 'Rejected',
        canceled: 'Canceled', # added to support cancellations caused by other match success
        back: 'Pending',
      }
    end

    def to_partial_path
      'match_decisions/fourteen/confirm_match_success'
    end

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('CoC Fourteen')} to confirm match success"
      when :confirmed then "#{Translation.translate('CoC Fourteen')} confirms match success#{move_in_date_label_suffix}"
      when :rejected then "Match rejected by #{Translation.translate('CoC Fourteen')}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def step_name
      Translation.translate('Confirm Match Success')
    end

    def actor_type
      Translation.translate('CoC Fourteen')
    end

    def contact_actor_type
      :dnd_staff_contacts
    end

    def permitted_params
      super + [:client_move_in_date]
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Fourteen::FourteenConfirmMatchSuccessDndStaff
        m << Notifications::Fourteen::FourteenConfirmMatchSuccessFyi
      end
    end

    def stallable?
      true
    end

    def stalled_contact_types
      [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :hsp_contacts, :dnd_staff_contacts, :ssp_contacts]
    end

    private def move_in_date_label_suffix
      return '' if client_move_in_date.blank?

      ", #{Translation.translate('lease start date')} #{client_move_in_date.strftime('%m/%d/%Y')}"
    end

    private def client_move_in_date_present_if_confirmed
      return unless show_move_in_date?

      errors.add :client_move_in_date, 'must be filled in' if status == 'confirmed' && client_move_in_date.blank?
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def confirmed
        Notifications::MatchSuccessConfirmed.create_for_match! match
        match.succeeded!(user: user)
      end

      def rejected
        Notifications::MatchRejected.create_for_match! match
        match.rejected!
      end
    end
    private_constant :StatusCallbacks
  end
end
