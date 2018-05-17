module MatchRoutes
  class ProviderOnly < Base

    def title
      _('Provider Only Route')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
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
       'MatchDecisions::ProviderOnly::ConfirmHsaAcceptsClientDeclineDndStaff' => 2,
       }
    end

    def initial_decision
      :hsa_acknowledges_receipt_decision
    end

  end
end