###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class HomelessSetAside < Base
    def title
      _('Homeless Set-Aside Route')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::HomelessSetAside::SetAsidesHsaAcceptsClient' => 1,
        'MatchDecisions::HomelessSetAside::SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator' => 2,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::HomelessSetAside::SetAsidesHsaAcceptsClient' => 1,
        'MatchDecisions::HomelessSetAside::SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator' => 2,
        'MatchDecisions::HomelessSetAside::SetAsidesConfirmHsaAcceptsClientDeclineDndStaff' => 3,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :set_asides_hsa_accepts_client_decision
    end

    def success_decision
      :set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision
    end

    def initial_contacts_for_match
      :housing_subsidy_admin_contacts
    end

    def default_program_type
      'Set-Aside'
    end

    def status_declined?(match)
      [
        match.set_asides_hsa_accepts_client_decision&.status == 'declined' &&
          match.set_asides_confirm_hsa_accepts_client_decline_dnd_staff_decision&.status != 'decline_overridden',
        match.set_asides_record_client_housed_date_or_decline_housing_subsidy_administrator_decision&.status &&
          match.set_asides_confirm_hsa_accepts_client_decline_dnd_staff_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
