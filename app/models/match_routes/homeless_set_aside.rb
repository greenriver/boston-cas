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
        'MatchDecisions::HomelessSetAside::SetAsidesHsaAcknowledgesReceipt' => 1,
        'MatchDecisions::HomelessSetAside::SetAsidesHsaAcceptsClient' => 2,
        'MatchDecisions::HomelessSetAside::SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator' => 3,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::HomelessSetAside::SetAsidesHsaAcknowledgesReceipt' => 1,
        'MatchDecisions::HomelessSetAside::SetAsidesHsaAcceptsClient' => 2,
        'MatchDecisions::HomelessSetAside::SetAsidesRecordClientHousedDateOrDeclineHousingSubsidyAdministrator' => 3,
        'MatchDecisions::HomelessSetAside::SetAsidesConfirmHsaAcceptsClientDeclineDndStaff' => 4,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :set_asides_hsa_acknowledges_receipt_decision
    end

    def initial_contacts_for_match
      :housing_subsidy_admin_contacts
    end
  end
end
