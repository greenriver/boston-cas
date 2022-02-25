###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  class ApproveMatchHousingSubsidyAdmin < Base
    include MatchDecisions::AcceptsDeclineReason

    # validate :note_present_if_status_declined

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{_('Housing Subsidy Administrator')} reviewing match"
      when :accepted then "Match accepted by #{_('Housing Subsidy Administrator')}"
      when :declined then "Match declined by #{_('Housing Subsidy Administrator')}.  Reason: #{decline_reason_name}"
      when :shelter_declined then "Match declined by #{_('Shelter Agency Contact')}.  Reason: #{decline_reason_name}"
      when :skipped then 'Skipped'
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.confirm_housing_subsidy_admin_decline_dnd_staff_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      _('Housing Subsidy Administrator CORI Hearing')
    end

    def actor_type
      _('HSA')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def include_additional_shelter_agency_decline?
      true
    end

    def statuses
      {
        pending: 'Pending',
        accepted: 'Accepted',
        declined: 'Declined',
        shelter_declined: 'Declined by Shelter Agency',
        canceled: 'Canceled',
        skipped: 'Skipped',
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
        :ssp_contacts,
        :hsp_contacts,
      ]
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      housing_scheduled = match&.schedule_criminal_hearing_housing_subsidy_admin_decision&.status == 'scheduled'
      @notifications_for_this_step ||= [].tap do |m|
        if match.nil? || housing_scheduled
          m << Notifications::CriminalHearingScheduledClient
          m << Notifications::CriminalHearingScheduledSsp
          m << Notifications::CriminalHearingScheduledHsp
          m << Notifications::CriminalHearingScheduledDndStaff
          m << Notifications::CriminalHearingScheduledShelterAgency
        end
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type
    end

    def accessible_by?(contact)
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.send(contact_actor_type))
    end

    def declineable_by?(contact)
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.shelter_agency_contacts)
    end

    private def decline_reason_scope(contact)
      if contact.user_can_act_on_behalf_of_match_contacts?
        MatchDecisionReasons::Base.where(type: ['MatchDecisionReasons::ShelterAgencyDecline', 'MatchDecisionReasons::HousingSubsidyAdminDecline'])
      elsif contact.in?(match.shelter_agency_contacts)
        MatchDecisionReasons::ShelterAgencyDecline.all
      else
        MatchDecisionReasons::HousingSubsidyAdminDecline.active
      end
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def accepted
        @decision.next_step.initialize_decision!
      end

      def declined
        match.confirm_housing_subsidy_admin_decline_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def shelter_declined
        @decision.class.transaction do
          @decision.update(status: nil)
          match.create_confirm_shelter_decline_of_hsa_approval_decision unless match.confirm_shelter_decline_of_hsa_approval_decision.present?
          match.confirm_shelter_decline_of_hsa_approval_decision.initialize_decision!
        end
      end
    end
    private_constant :StatusCallbacks

    private def note_present_if_status_declined
      errors.add :note, 'Please note why the match is declined.' if note.blank? && status.in?(['declined'])
    end
  end
end
