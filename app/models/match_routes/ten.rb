###
# Copyright 2016 - 2023 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Ten < Base
    def title
      _('Match Route Ten')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Ten::TenAgencyConfirmMatchSuccess' => 1,
        'MatchDecisions::Ten::TenConfirmMatchSuccessDndStaff' => 2,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Ten::TenAgencyConfirmMatchSuccess' => 1,
        'MatchDecisions::Ten::TenAgencyConfirmMatchSuccessDecline' => 2,
        'MatchDecisions::Ten::TenConfirmMatchSuccessDndStaff' => 3,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'shelter_agency_contacts',
        'housing_subsidy_admin',
      ]
    end

    def contact_label_for(contact_type)
      case contact_type
      when :dnd_staff_contacts
        _('DND')
      when :housing_subsidy_admin_contacts
        _('HSA Ten')
      when :shelter_agency_contacts
        _('Shelter Agency Ten')
      else
        super
      end
    end

    def initial_decision
      :ten_agency_confirm_match_success_decision
    end

    def success_decision
      :ten_confirm_match_success_dnd_staff_decision
    end

    def initial_contacts_for_match
      :housing_subsidy_admin_contacts
    end

    def status_declined?(match)
      [
        match.ten_agency_confirm_match_success_decision&.status == 'declined',
      ].any?
    end
  end
end
