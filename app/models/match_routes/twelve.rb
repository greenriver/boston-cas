###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Twelve < Base
    def title
      Translation.translate('Match Route Twelve')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Twelve::TwelveAgencyAcknowledgesReceipt' => 1,
        'MatchDecisions::Twelve::TwelveHsaConfirmMatchSuccess' => 2,
        'MatchDecisions::Twelve::TwelveConfirmMatchSuccessDndStaff' => 3,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Twelve::TwelveAgencyAcknowledgesReceipt' => 1,
        'MatchDecisions::Twelve::TwelveAgencyAcknowledgesReceiptDecline' => 2,
        'MatchDecisions::Twelve::TwelveHsaConfirmMatchSuccess' => 3,
        'MatchDecisions::Twelve::TwelveHsaConfirmMatchDecline' => 4,
        'MatchDecisions::Twelve::TwelveConfirmMatchSuccessDndStaff' => 5,
      }
    end

    def required_contact_types
      [
        'dnd_staff_contacts',
        'shelter_agency_contacts',
        'housing_subsidy_admin_contacts',
      ]
    end

    def contact_label_for(contact_type)
      case contact_type
      when :dnd_staff_contacts
        Translation.translate('CoC Twelve')
      when :housing_subsidy_admin_contacts
        Translation.translate('HSA Twelve')
      when :shelter_agency_contacts
        Translation.translate('Shelter Agency Twelve')
      else
        super
      end
    end

    def initial_decision
      :twelve_agency_acknowledges_receipt_decision
    end

    def success_decision
      :twelve_confirm_match_success_dnd_staff_decision
    end

    def initial_contacts_for_match
      :shelter_agency_contacts
    end

    def status_declined?(match)
      [
        match.twelve_agency_acknowledges_receipt_decision&.status == 'declined',
        match.twelve_hsa_confirm_match_success_decision&.status == 'declined',
        match.twelve_confirm_match_success_dnd_staff_decision&.status == 'declined',
      ].any?
    end
  end
end
