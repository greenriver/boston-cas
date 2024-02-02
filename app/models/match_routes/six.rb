###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Six < Base
    def title
      _('Match Route Six')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
        'MatchDecisions::Six::MatchRecommendationDndStaff' => 1,
        'MatchDecisions::Six::MatchRecommendationShelterAgency' => 2,
        'MatchDecisions::Six::ApproveMatchHousingSubsidyAdmin' => 3,
        'MatchDecisions::Six::ConfirmMatchSuccessDndStaff' => 4,
      }
    end

    def self.match_steps_for_reporting
      {
        'MatchDecisions::Six::MatchRecommendationDndStaff' => 1,
        'MatchDecisions::Six::MatchRecommendationShelterAgency' => 2,
        'MatchDecisions::Six::ConfirmShelterAgencyDeclineDndStaff' => 3,
        'MatchDecisions::Six::ApproveMatchHousingSubsidyAdmin' => 4,
        'MatchDecisions::Six::ConfirmHousingSubsidyAdminDeclineDndStaff' => 5,
        'MatchDecisions::Six::ConfirmMatchSuccessDndStaff' => 6,
      }
    end

    def initial_decision
      :six_match_recommendation_dnd_staff_decision
    end

    def success_decision
      :six_confirm_match_success_dnd_staff_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def show_hearing_date
      false
    end

    def status_declined?(match)
      [
        match.six_match_recommendation_dnd_staff_decision&.status == 'declined',
        match.six_match_recommendation_shelter_agency_decision&.status == 'declined' &&
          match.six_confirm_shelter_agency_decline_dnd_staff_decision&.status != 'decline_overridden',
        match.six_approve_match_housing_subsidy_admin_decision&.status == 'declined' &&
          match.six_confirm_housing_subsidy_admin_decline_dnd_staff_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
