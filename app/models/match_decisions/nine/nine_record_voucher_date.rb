###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Nine
  class NineRecordVoucherDate < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason

    validate :date_voucher_issued_present_if_status_accept
    validate :ensure_required_contacts_present_on_accept

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{_('Housing Subsidy Administrator Nine')} reviewing match"
      when :accepted then "#{_('Housing Subsidy Administrator Nine')} issued voucher on  #{date_voucher_issued.try :strftime, '%m/%d/%Y'}"
      when :declined then "Match declined by #{_('Housing Subsidy Administrator Nine')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.nine_confirm_voucher_decline_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      _('Record Date Voucher Issued')
    end

    def actor_type
      _('HSA Nine')
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

    def editable?
      super && saved_status !~ /accepted|declined/
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
        m << Notifications::Nine::NineRecordVoucherDate
        m << Notifications::Nine::NineMatchInProgress
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
        contact.in?(match.send(contact_actor_type))
    end

    # def to_param
    #   :nine_record_voucher_date_housing_subsidy_admin
    # end

    def step_decline_reasons(_contact)
      @step_decline_reasons ||= [
        'Immigration status',
        'Ineligible for Housing Program',
        'Self-resolved',
        'Household did not respond after initial acceptance of match',
        'Client refused offer',
        'Client needs higher level of care',
        'Unable to reach client after multiple attempts',
        'Other',
      ].freeze
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        Notifications::MatchDeclined.create_for_match! match
        match.nine_confirm_voucher_decline_decision.initialize_decision!
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

    private def date_voucher_issued_present_if_status_accept
      errors.add :date_voucher_issued, 'must be filled in' if status == 'accepted' && date_voucher_issued.blank?
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{_('Housing Subsidy Administrator Nine')} Contact" if status == 'accepted' && match.housing_subsidy_admin_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end
  end
end
