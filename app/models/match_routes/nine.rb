###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Nine < Base
    def title
      _('Match Route Nine')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Nine::MatchRecommendationDndStaff' => 1,
        'MatchDecisions::Nine::RecordVoucherDateHousingSubsidyAdmin' => 2,
        'MatchDecisions::Nine::LeaseUp' => 3,
        'MatchDecisions::Nine::ConfirmMatchSuccessDndStaff' => 4,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Nine::MatchRecommendationDndStaff' => 1,
        'MatchDecisions::Nine::RecordVoucherDateHousingSubsidyAdmin' => 2,
        'MatchDecisions::Nine::ConfirmHousingSubsidyAdminDeclineDndStaff' => 3,
        'MatchDecisions::Nine::LeaseUp' => 4,
        'MatchDecisions::Nine::ConfirmMatchSuccessDndStaff' => 5,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :nine_match_recommendation_dnd_staff_decision
    end

    def success_decision
      :nine_confirm_match_success_dnd_staff_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def show_hearing_date
      false
    end
  end
end