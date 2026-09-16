###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

module MatchDecisions::Fourteen
  class FourteenSubsidyAdminScreening < Base
    include MatchDecisions::AcceptsDeclineReason

    validate :ensure_required_contacts_present_on_accept

    def to_partial_path
      'match_decisions/fourteen/subsidy_admin_screening'
    end

    def step_name
      'Subsidy Administrator Screening'
    end

    def actor_type
      Translation.translate('HSA Fourteen')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    # Notifications to send when this step is initiated
    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Fourteen::FourteenSubsidyAdminScreeningHsa
        m << Notifications::Fourteen::FourteenSubsidyAdminScreeningFyi
      end
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        canceled: 'Canceled',
        declined: 'Declined',
        skipped: 'Skipped',
        back: 'Pending',
      }
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('HSA Fourteen')} assigned match"
      when :accepted then "Match Reviewed by #{Translation.translate('HSA Fourteen')}."
      when :canceled then canceled_status_label
      when :declined then "Match Declined.  Reason: #{decline_reason_name}"
      when :skipped then 'Skipped'
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
      [:shelter_agency_contacts, :housing_subsidy_admin_contacts, :hsp_contacts, :dnd_staff_contacts, :ssp_contacts]
    end

    private def ensure_required_contacts_present_on_accept
      missing_contacts = []
      missing_contacts << "a #{Translation.translate('HSA Fourteen')} Contact" if save_will_accept? && match.send(contact_actor_type).none?

      errors.add :match_contacts, "needs #{missing_contacts.to_sentence}" if missing_contacts.any?
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
        match.fourteen_subsidy_admin_screening_decline_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks
  end
end
