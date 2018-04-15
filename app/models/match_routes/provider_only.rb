module MatchRoutes
  class ProviderOnly < Base

    def title
      _('Provider Only Route')
    end

    def self.available_sub_types_for_search
      [
        'MatchDecisions::ApproveMatchHousingSubsidyAdmin',
      ]
    end

    def self.match_steps
      {
       'MatchDecisions::ProviderOnly::HsaAcknowledgesReceipt' => 1,
       'MatchDecisions::ProviderOnly::HsaAcceptsClient' => 2,
      }
    end

    def self.match_steps_for_reporting
      {
       'MatchDecisions::ProviderOnly::HsaAcknowledgesReceipt' => 1,
       'MatchDecisions::ProviderOnly::HsaAcceptsClient' => 2,
       'MatchDecisions::ProviderOnly::ConfirmHsaAcceptsClientDeclineDndStaffDecision' => 2,
       # 'MatchDecisions::ConfirmShelterAgencyDeclineDndStaff' => 3,
       # 'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin' => 4,
       # 'MatchDecisions::ApproveMatchHousingSubsidyAdmin' => 5,
       # 'MatchDecisions::ConfirmHousingSubsidyAdminDeclineDndStaff' => 6,
       # 'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator' => 7,
       # 'MatchDecisions::ConfirmMatchSuccessDndStaff' => 8,
       }
    end

    def initial_decision
      :hsa_acknowledges_receipt_decision
    end

  end
end