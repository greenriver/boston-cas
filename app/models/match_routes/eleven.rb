###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Eleven < Base
    def title
      Translation.translate('Match Route Eleven')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Eleven::ElevenHsaAcknowledgesReceipt' => 1,
        'MatchDecisions::Eleven::ElevenHsaAcceptsClient' => 2,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Eleven::ElevenHsaAcknowledgesReceipt' => 1,
        'MatchDecisions::Eleven::ElevenHsaAcceptsClient' => 2,
        'MatchDecisions::Eleven::ElevenConfirmHsaAcceptsClientDeclineDndStaff' => 2,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :eleven_hsa_acknowledges_receipt_decision
    end

    def success_decision
      :eleven_hsa_accepts_client_decision
    end

    def initial_contacts_for_match
      :housing_subsidy_admin_contacts
    end

    def status_declined?(match)
      [
        match.eleven_hsa_accepts_client_decision&.status == 'declined' &&
          match.eleven_confirm_hsa_accepts_client_decline_dnd_staff_decision&.status != 'decline_overridden',
      ].any?
    end

    def contact_label_for(contact_type)
      case contact_type&.to_sym
      when :dnd_staff_contacts
        Translation.translate('CoC Eleven')
      when :housing_subsidy_admin_contacts
        Translation.translate('Housing Subsidy Administrator Eleven')
      when :shelter_agency_contacts
        Translation.translate('Shelter Agency Eleven')
      when :ssp_contacts
        Translation.translate('Stabilization Service Provider Eleven')
      when :hsp_contacts
        Translation.translate('Housing Search Provider Eleven')
      else
        super(contact_type)
      end
    end
  end
end
