###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchDecisions
  class RecordClientHousedDateHousingSubsidyAdministrator < Base
    include MatchDecisions::AcceptsDeclineReason # For shelter agency declines
    include MatchDecisions::DefaultShelterAgencyDeclineReasons

    attr_accessor :building_id
    attr_accessor :unit_id

    validate :client_move_in_date_present_if_status_complete

    def label
      label_for_status status
    end

    def label_for_status status
      case status.to_sym
      when :pending then "#{_('Housing Subsidy Administrator')} to note when client will move in."
      when :other_clients_canceled then "#{_('Housing Subsidy Administrator')} has confirmed client will move-in, and has canceled other matches on the opportunity"
      when :completed then "#{_('Housing Subsidy Administrator')} notes lease start date #{client_move_in_date.try :strftime, '%m/%d/%Y'}"
      when :shelter_declined then "Match declined by #{_('Shelter Agency Contact')}.  Reason: #{decline_reason_name}"
      when :skipped then 'Skipped'
      when :canceled then canceled_status_label
      when :back then backup_status_label
      end
    end

    def step_name
      'Indicate date client was housed'
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
        other_clients_canceled: 'Pending, other matches on opportunity canceled',
        completed: 'Complete',
        canceled: 'Canceled',
        shelter_declined: 'Declined by Shelter Agency',
        skipped: _('There will not be a criminal background hearing'),
        back: 'Pending',
      }
    end

    def editable?
      super && saved_status !~ /complete/
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
      update(status: 'pending')
      StatusCallbacks.new(self, nil).pending

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

    def holds_voucher?
      ! match.has_buildings?
    end

    class StatusCallbacks < StatusCallbacks
      def pending
        match.client.update(holds_voucher_on: Date.current, holds_internal_cas_voucher: true) unless match.has_buildings?
      end

      def other_clients_canceled
        match.cancel_opportunity_related_matches!
      end

      def completed
        match.client.update(holds_voucher_on: nil, holds_internal_cas_voucher: nil)
        @decision.next_step.initialize_decision!
      end

      def canceled
        match.client.update(holds_voucher_on: nil, holds_internal_cas_voucher: nil)
        Notifications::MatchCanceled.create_for_match! match
        match.canceled!
      end

      def shelter_declined
        @decision.class.transaction do
          match.create_confirm_shelter_decline_of_housed_decision unless match.confirm_shelter_decline_of_housed_decision.present?
          match.confirm_shelter_decline_of_housed_decision.initialize_decision!
        end
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
