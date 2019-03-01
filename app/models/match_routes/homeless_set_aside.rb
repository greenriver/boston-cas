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
          'MatchDecisions::HomelessSetAside::HsaAcknowledgesReceipt' => 1,
          'MatchDecisions::HomelessSetAside::HsaAcceptsClient' => 2,
          'MatchDecisions::HomelessSetAside::RecordClientHousedDateHousingSubsidyAdministrator' => 3,
      }
    end

    def self.match_steps_for_reporting
      {
          'MatchDecisions::HomelessSetAside::HsaAcknowledgesReceipt' => 1,
          'MatchDecisions::HomelessSetAside::HsaAcceptsClient' => 2,
          'MatchDecisions::HomelessSetAside::RecordClientHousedDateHousingSubsidyAdministrator' => 3,
          'MatchDecisions::HomelessSetAside::ConfirmHsaAcceptsClientDeclineDndStaff' => 2,
      }
    end

    def required_contact_types
      [
          'dnd_staff',
          'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :hsa_acknowledges_receipt_decision
    end

  end
end