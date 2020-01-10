###
# Copyright 2016 - 2020 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/master/LICENSE.md
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

    def initial_contacts_for_match
      :housing_subsidy_admin_contacts
    end

    def default_program_type
      'Set-Aside'
    end
  end
end