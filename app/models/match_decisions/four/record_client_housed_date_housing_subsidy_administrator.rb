###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions::Four
  class RecordClientHousedDateHousingSubsidyAdministrator < ::MatchDecisions::Base
    include MatchDecisions::RouteFourCancelReasons

    attr_accessor :building_id
    attr_accessor :unit_id

    validate :client_move_in_date_present_if_status_complete

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{Translation.translate('Housing Subsidy Administrator')} to note when client will move in."
      when :completed then "#{Translation.translate('Housing Subsidy Administrator')} notes #{Translation.translate('lease start date')} #{client_move_in_date.try :strftime, '%m/%d/%Y'}"
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def step_name
      'Indicate date client was housed'
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
        completed: 'Complete',
        canceled: 'Canceled',
        back: 'Pending',
      }
    end

    def started?
      status&.to_sym == :completed
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
      contact&.user_can_act_on_behalf_of_match_contacts? ||
      contact&.in?(match.housing_subsidy_admin_contacts)
    end

    def to_param
      :four_record_client_housed_date_housing_subsidy_administrator
    end

    class StatusCallbacks < StatusCallbacks
      def pending
      end

      def completed
        @decision.next_step.initialize_decision!
      end

      def canceled
        Notifications::Four::MatchCanceled.create_for_match! match
        match.canceled!
      end
    end
    private_constant :StatusCallbacks

    def whitelist_params_for_update params
      super.merge params.require(:decision).permit(
        :building_id,
        :unit_id,
        :external_software_used,
        :address,
      )
    end

    private def client_move_in_date_present_if_status_complete
      errors.add :client_move_in_date, 'must be filled in' if status == 'completed' && client_move_in_date.blank?
      errors.add :address, 'must be filled in' if status == 'completed' && match.sub_program.program_type != 'Tenant-Based' && address.blank? && match.opportunity.voucher.unit.blank?
    end
  end
end
