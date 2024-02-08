###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class ProviderOnly < Base
    def title
      Translation.translate('Provider Only Route')
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

    def required_contact_types
      [
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :hsa_acknowledges_receipt_decision
    end

    def success_decision
      :hsa_accepts_client_decision
    end

    def initial_contacts_for_match
      :housing_subsidy_admin_contacts
    end

    def status_declined?(match)
      [
        match.hsa_accepts_client_decision&.status == 'declined' &&
          match.confirm_hsa_accepts_client_decline_dnd_staff_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
