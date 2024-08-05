###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Thirteen
  class ThirteenAcceptReferral < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::RouteThirteenCancelReasons
    include MatchDecisions::RouteThirteenDeclineReasons

    validate :ensure_required_contacts_present_on_accept
    validate :ensure_required_contacts_present_on_accept

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
      when :accepted then "Referral Accepted by #{Translation.translate('HSA Thirteen')}."
      when :canceled then canceled_status_label
      when :declined then 'Match Declined'
      when :back then backup_status_label
      end
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('Shelter Agency Thirteen')} Contact" if save_will_accept? && match.shelter_agency_contacts.none?
      missing_contacts << "a #{Translation.translate('SSP Thirteen')} Contact" if save_will_accept? && match.ssp_contacts.none?
      missing_contacts << "a #{Translation.translate('HSP Thirteen')} Contact" if save_will_accept? && match.hsp_contacts.none?

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
