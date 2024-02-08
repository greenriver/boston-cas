###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Four
  class ScheduleCriminalHearingHousingSubsidyAdmin < ::MatchDecisions::Base
    include MatchDecisions::RouteFourCancelReasons

    validate :criminal_hearing_date_present_if_scheduled
    validate :criminal_hearing_date_absent_if_no_hearing

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Housing Subsidy Administrator')} #{Translation.translate('researching criminal background and deciding whether to schedule a hearing')}"
      when :scheduled then "#{Translation.translate('Housing Subsidy Administrator')} #{Translation.translate('has scheduled criminal background hearing for')} <strong>#{criminal_hearing_date}</strong>".html_safe
      when :no_hearing then "#{Translation.translate('Housing Subsidy Administrator')} #{Translation.translate('indicates there will not be a criminal background hearing')}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def step_name
      "#{Translation.translate('Housing Subsidy Administrator')} Reviews Match"
    end

    def actor_type
      Translation.translate('HSA')
    end

    def contact_actor_type
      :housing_subsidy_admin_contacts
    end

    def statuses
      {
        pending: 'Pending',
        scheduled: Translation.translate('Criminal Background Hearing Scheduled'),
        no_hearing: Translation.translate('There will not be a criminal background hearing'),
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def started?
      status&.to_sym.in?([:scheduled, :no_hearing])
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

    def initialize_decision! send_notifications: true
      super(send_notifications: send_notifications)
      update status: 'pending'
      send_notifications_for_step if send_notifications
    end

    def notifications_for_this_step
      @notifications_for_this_step ||= [].tap do |m|
        m << Notifications::Four::ScheduleCriminalHearingSsp
        m << Notifications::Four::ScheduleCriminalHearingHsp
        m << Notifications::Four::HousingSubsidyAdministratorAccepted
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def permitted_params
      super + [:criminal_hearing_date]
    end

    def accessible_by? contact
      contact&.user_can_act_on_behalf_of_match_contacts? ||
      contact&.in?(match.housing_subsidy_admin_contacts)
    end

    def to_param
      :four_schedule_criminal_hearing_housing_subsidy_admin
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def scheduled
        @decision.next_step.initialize_decision!
      end

      def no_hearing
        # Set the next step status to approved and skip the next step
        @decision.next_step.update!(status: :accepted)
        @decision.next_step.next_step.initialize_decision!
      end

      def canceled
        Notifications::Four::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    private

    def criminal_hearing_date_present_if_scheduled
      errors.add :criminal_hearing_date, 'must be filled in' if status == 'scheduled' && criminal_hearing_date.blank?
    end

    def criminal_hearing_date_absent_if_no_hearing
      errors.add :criminal_hearing_date, 'must not be filled in' if status == 'no_hearing' && criminal_hearing_date.present?
    end
  end
end
