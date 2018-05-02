module MatchRoutes
  class Default < Base

    def title
      _('Default Match Route')
    end

    def self.available_sub_types_for_search
      match_steps_for_reporting.keys
    end
    
    def self.match_steps
      {
       'MatchDecisions::MatchRecommendationDndStaff' => 1,
       'MatchDecisions::MatchRecommendationShelterAgency' => 2,
       'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin' => 3,
       'MatchDecisions::ApproveMatchHousingSubsidyAdmin' => 4,
       'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator' => 5,
       'MatchDecisions::ConfirmMatchSuccessDndStaff' => 6,
      }
    end

    def self.match_steps_for_reporting
      {
       'MatchDecisions::MatchRecommendationDndStaff' => 1,
       'MatchDecisions::MatchRecommendationShelterAgency' => 2,
       'MatchDecisions::ConfirmShelterAgencyDeclineDndStaff' => 3,
       'MatchDecisions::ScheduleCriminalHearingHousingSubsidyAdmin' => 4,
       'MatchDecisions::ApproveMatchHousingSubsidyAdmin' => 5,
       'MatchDecisions::ConfirmHousingSubsidyAdminDeclineDndStaff' => 6,
       'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator' => 7,
       'MatchDecisions::ConfirmMatchSuccessDndStaff' => 8,
       }
    end

    def initial_decision
      :match_recommendation_dnd_staff_decision
    end
  end
end