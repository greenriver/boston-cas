###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Eight
  class EightRecordVoucherDate < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    validate :date_voucher_issued_present_if_status_complete

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Housing Subsidy Administrator Eight')} reviewing match"
      when :accepted then "#{Translation.translate('Housing Subsidy Administrator Eight')} issued voucher on  #{date_voucher_issued.try :strftime, '%m/%d/%Y'}"
      when :declined then "Match declined by #{Translation.translate('Housing Subsidy Administrator Eight')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def status_label
      if match.eight_confirm_voucher_decline_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      Translation.translate('Record Date Voucher Issued')
    end

    def actor_type
      Translation.translate('HSA Eight')
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
        m << Notifications::Eight::EightRecordVoucherDate
      end
    end

    def notify_on_behalf_of?
      true
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
        contact.in?(match.send(contact_actor_type))
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        Notifications::MatchDeclined.create_for_match! match
        match.eight_confirm_voucher_decline_decision.initialize_decision!
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

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :date_voucher_issued,
      )
    end

    private def date_voucher_issued_present_if_status_complete
      errors.add :date_voucher_issued, 'must be filled in' if status == 'accepted' && date_voucher_issued.blank?
    end
  end
end
