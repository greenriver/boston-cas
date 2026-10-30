###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Thirteen
  class ThirteenAcceptReferral < Base
    include MatchDecisions::AcceptsDeclineReason

    validate :ensure_required_contacts_present_on_accept
    validate :ensure_required_contacts_present_on_accept
    validate :date_voucher_issued_present_if_status_complete

    def to_partial_path
      'match_decisions/thirteen/accept_referral'
    end

    def step_name
      'Accept Referral'
    end

    def actor_type
      Translation.translate('HSA Thirteen')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    # Notifications to send when this step is initiated
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Thirteen::ThirteenAcceptReferralShelterAgency
        m << Notifications::Thirteen::ThirteenAcceptReferralHsa
        m << Notifications::Thirteen::ThirteenAcceptReferralSsp
        m << Notifications::Thirteen::ThirteenAcceptReferralHsp
      end
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        canceled: 'Canceled',
        declined: 'Declined',
        back: 'Pending',
      }
    end

    def permitted_params
      super + [:date_voucher_issued]
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('HSA Thirteen')} assigned match"
      when :accepted
        text = "Referral Accepted by #{Translation.translate('HSA Thirteen')}."
        text += " #{Translation.translate('Date voucher issued')}: #{date_voucher_issued.try(:strftime, '%m/%d/%Y')}" if date_voucher_issued.present?
        text
      when :canceled then canceled_status_label
      when :declined then "Match Declined.  Reason: #{decline_reason_name}"
      when :back then backup_status_label
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def stallable?
      true
    end

    def stalled_contact_types
      @stalled_contact_types ||= [
        :shelter_agency_contacts,
        :housing_subsidy_admin_contacts,
        :dnd_staff_contacts,
        :ssp_contacts,
        :do_contacts,
      ]
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('Shelter Agency Thirteen')} Contact" if save_will_accept? && match.shelter_agency_contacts.none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
    end

    private def date_voucher_issued_present_if_status_complete
      errors.add :date_voucher_issued, 'must be filled in' if status == 'accepted' && date_voucher_issued.blank?
    end

    private def save_will_accept?
      saved_status == 'pending' && status == 'accepted'
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        Notifications::MatchDeclined.create_for_match! match
        match.thirteen_accept_referral_decline_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
