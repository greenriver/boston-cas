###
# Copyright 2016 - 2021 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Four < Base

    def title
      _('Match Route Four')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end

    def self.match_steps
      {
       'MatchDecisions::Four::MatchRecommendationDndStaff' => 1,
       'MatchDecisions::Four::MatchRecommendationShelterAgency' => 2,
       'MatchDecisions::Four::MatchRecommendationHsa' => 3,
       'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin' => 4,
       'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin' => 5,
       'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator' => 6,
       'MatchDecisions::Four::ConfirmMatchSuccessDndStaff' => 7,
      }
    end

    def self.match_steps_for_reporting
      {
       'MatchDecisions::Four::MatchRecommendationDndStaff' => 1,
       'MatchDecisions::Four::MatchRecommendationShelterAgency' => 2,
       'MatchDecisions::Four::ConfirmShelterAgencyDeclineDndStaff' => 3,
       'MatchDecisions::Four::MatchRecommendationHsa' => 4,
       'MatchDecisions::Four::ConfirmHsaInitialDeclineDndStaff' => 5,
       'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin' => 6,
       'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin' => 7,
       'MatchDecisions::Four::ConfirmHousingSubsidyAdminDeclineDndStaff' => 8,
       'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator' => 9,
       'MatchDecisions::Four::ConfirmMatchSuccessDndStaff' => 10,
       }
    end

    def initial_decision
      :four_match_recommendation_dnd_staff_decision
    end

    def success_decision
      :four_confirm_match_success_dnd_staff_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end
  end
end
