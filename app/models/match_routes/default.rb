###
# Copyright 2016 - 2024 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/boston-cas/blob/production/LICENSE.md
###

module MatchRoutes
  class Default < Base
    def title
      Translation.translate('Default Match Route')
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
        'MatchDecisions::ConfirmShelterDeclineOfHearing' => 5,
        'MatchDecisions::ApproveMatchHousingSubsidyAdmin' => 6,
        'MatchDecisions::ConfirmShelterDeclineOfHsaApproval' => 7,
        'MatchDecisions::ConfirmHousingSubsidyAdminDeclineDndStaff' => 8,
        'MatchDecisions::RecordClientHousedDateHousingSubsidyAdministrator' => 9,
        'MatchDecisions::ConfirmShelterDeclineOfHoused' => 10,
        'MatchDecisions::ConfirmMatchSuccessDndStaff' => 11,
      }
    end

    def first_client_step
      'MatchDecisions::MatchRecommendationShelterAgency'
    end

    def initial_decision
      :match_recommendation_dnd_staff_decision
    end

    def success_decision
      :confirm_match_success_dnd_staff_decision
    end

    def initial_contacts_for_match
      :dnd_staff_contacts
    end

    def status_declined?(match)
      [
        match.match_recommendation_dnd_staff_decision&.status == 'declined',
        match.match_recommendation_shelter_agency_decision&.status == 'declined' &&
          match.confirm_shelter_agency_decline_dnd_staff_decision&.status != 'decline_overridden',
        match.approve_match_housing_subsidy_admin_decision&.status == 'declined' &&
          match.confirm_housing_subsidy_admin_decline_dnd_staff_decision&.status != 'decline_overridden',
      ].any?
    end
  end
end
