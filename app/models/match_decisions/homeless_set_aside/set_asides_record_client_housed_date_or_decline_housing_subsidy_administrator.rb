###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::HomelessSetAside
  class SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator < ::MatchDecisions::Base
    include MatchDecisions::AcceptsDeclineReason
    include MatchDecisions::DefaultSetAsidesDeclineReasons

    attr_accessor :building_id
    attr_accessor :unit_id

    validate :client_move_in_date_present_if_status_complete

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Housing Subsidy Administrator')} to note when client will move in."
      when :other_clients_canceled then "#{Translation.translate('Housing Subsidy Administrator')} has confirmed client will move-in, and has canceled other matches on the opportunity"
      when :completed then "#{Translation.translate('Housing Subsidy Administrator')} notes #{Translation.translate('lease start date')} #{client_move_in_date.try :strftime, '%m/%d/%Y'}"
      when :declined then "Match declined by #{Translation.translate('Housing Subsidy Administrator')}.  Reason: #{decline_reason_name}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    # if we've overridden this decision, indicate that (this is sent to the client)
    def status_label
      if match.set_asides_confirm_hsa_accepts_client_decline_dnd_staff_decision.status == 'decline_overridden'
        'Approved'
      else
        statuses[status && status.to_sym]
      end
    end

    def step_name
      "#{Translation.translate('HSA')} Indicates date client was housed"
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
        other_clients_canceled: 'Pending, other matches on opportunity canceled',
        completed: 'Complete',
        declined: 'Declined',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def started?
      status&.to_sym == :completed
    end

    def editable?
      super && saved_status !~ /complete|declined/
    end

    def stallable?
      true
    end

    def stalled_contact_types
      @stalled_contact_types ||= [
        :shelter_agency_contacts,
        :ssp_contacts,
        :hsp_contacts,
      ]
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
        m << Notifications::HousingSubsidyAdminDecisionClient
        m << Notifications::HousingSubsidyAdminDecisionShelterAgency
        m << Notifications::HousingSubsidyAdminDecisionSsp
        m << Notifications::HousingSubsidyAdminDecisionHsp
        m << Notifications::HousingSubsidyAdminAcceptedMatchDndStaff
        m << Notifications::HousingSubsidyAdminDecisionDevelopmentOfficer
      end
    end

    def notify_contact_of_action_taken_on_behalf_of contact: # rubocop:disable Lint/UnusedMethodArgument
      Notifications::OnBehalfOf.create_for_match! match, contact_actor_type unless status == 'canceled'
    end

    def accessible_by? contact
      contact.user_can_act_on_behalf_of_match_contacts? ||
          contact.in?(match.housing_subsidy_admin_contacts)
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def other_clients_canceled
        match.cancel_opportunity_related_matches!
      end

      def completed
        match.succeeded!
      end

      def declined
        match.set_asides_confirm_hsa_accepts_client_decline_dnd_staff_decision.initialize_decision!
      end

      def canceled
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :building_id,
        :unit_id,
      )
    end

    private def client_move_in_date_present_if_status_complete
      errors.add :client_move_in_date, 'must be filled in' if status == 'completed' && client_move_in_date.blank?
    end
  end
end
