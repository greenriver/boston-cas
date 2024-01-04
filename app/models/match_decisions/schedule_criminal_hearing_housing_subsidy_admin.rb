###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  class ScheduleCriminalHearingHousingSubsidyAdmin < Base
    include MatchDecisions::AcceptsDeclineReason # For shelter agency declines

    validate :criminal_hearing_date_present_if_scheduled
    validate :criminal_hearing_date_absent_if_no_hearing

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{_('Housing Subsidy Administrator')} #{_('researching criminal background and deciding whether to schedule a hearing')}"
      when :scheduled then "#{_('Housing Subsidy Administrator')} #{_('has scheduled criminal background hearing for')} <strong>#{criminal_hearing_date}</strong>".html_safe
      when :no_hearing then "#{_('Housing Subsidy Administrator')} #{_('indicates there will not be a criminal background hearing')}"
      when :shelter_declined then "Match declined by #{_('Shelter Agency Contact')}.  Reason: #{decline_reason_name}"
      when :skipped then 'Skipped'
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def started?
      status&.to_sym.in?([:scheduled, :no_hearing, :skipped])
    end

    def step_name
      "#{_('Housing Subsidy Administrator')} Reviews Match"
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
        scheduled: _('Criminal Background Hearing Scheduled'),
        no_hearing: _('There will not be a criminal background hearing'),
        canceled: 'Canceled',
        shelter_declined: 'Declined by Shelter Agency',
        back: 'Pending',
        skipped: _('There will not be a criminal background hearing'),
      }
    end

    def editable?
      super && saved_status !~ /scheduled|no_hearing/
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

    def step_decline_reasons(_contact)
      [
        'Client has another housing option',
        'Does not agree to services',
        'Unwilling to live in that neighborhood',
        'Unwilling to live in SRO',
        'Does not want housing at this time',
        'Unsafe environment for this person',
        'Client refused unit (non-SRO)',
        'Client refused voucher',
        'Health and Safety',
      ]
    end

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::ScheduleCriminalHearingHousingSubsidyAdmin
        m << Notifications::ScheduleCriminalHearingSsp
        m << Notifications::ScheduleCriminalHearingHsp
        m << Notifications::ShelterAgencyAccepted
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def permitted_params
      super + [:criminal_hearing_date]
    end

    def accessible_by?(contact)
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.send(contact_actor_type))
    end

    def declineable_by?(contact)
      contact.user_can_act_on_behalf_of_match_contacts? ||
      contact.in?(match.shelter_agency_contacts)
    end

    def show_client_match_attributes?
      true
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      # This is only used for tests when checking stall state
      def accepted
      end

      def scheduled
        @decision.next_step.initialize_decision!
      end

      def no_hearing
        # Set the next step status to approved and skip the next step
        @decision.next_step.update(status: :skipped)
        @decision.next_step.next_step.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def shelter_declined
        @decision.class.transaction do
          match.create_confirm_shelter_decline_of_hearing_decision unless match.confirm_shelter_decline_of_hearing_decision.present?
          match.confirm_shelter_decline_of_hearing_decision.initialize_decision!
        end
      end
    end
    private_constant :StatusCallbacks

    private def criminal_hearing_date_present_if_scheduled
      errors.add :criminal_hearing_date, 'must be filled in' if status == 'scheduled' && criminal_hearing_date.blank?
    end

    private def criminal_hearing_date_absent_if_no_hearing
      errors.add :criminal_hearing_date, 'must not be filled in' if status == 'no_hearing' && criminal_hearing_date.present?
    end
  end
end
