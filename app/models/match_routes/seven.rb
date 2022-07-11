###
# Copyright 2016 - 2022 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Seven < Base
    def title
      _('Match Route Seven')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Seven::MatchRecommendationDndStaff' => 1,
        'MatchDecisions::Seven::ApproveMatchHousingSubsidyAdmin' => 2,
        'MatchDecisions::Seven::ConfirmMatchSuccessDndStaff' => 3,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Seven::MatchRecommendationDndStaff' => 1,
        'MatchDecisions::Seven::ApproveMatchHousingSubsidyAdmin' => 2,
        'MatchDecisions::Seven::ConfirmHousingSubsidyAdminDeclineDndStaff' => 3,
        'MatchDecisions::Seven::ConfirmMatchSuccessDndStaff' => 4,
      }
    end

    def required_contact_types
      [
        'dnd_staff',
        'housing_subsidy_admin',
      ]
    end

    def initial_decision
      :seven_match_recommendation_dnd_staff_decision
    end

    def success_decision
      :seven_confirm_match_success_dnd_staff_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end
  end
end
