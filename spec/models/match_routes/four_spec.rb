###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchRoutes::Four, type: :model do
  describe '.match_steps' do
    it 'is unchanged by the new decline steps (mainline sequence stays untouched)' do
      expect(described_class.match_steps).to eq(
        'MatchDecisions::Four::MatchRecommendationDndStaff' => 1,
        'MatchDecisions::Four::MatchRecommendationShelterAgency' => 2,
        'MatchDecisions::Four::MatchRecommendationHsa' => 3,
        'MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin' => 4,
        'MatchDecisions::Four::ApproveMatchHousingSubsidyAdmin' => 5,
        'MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator' => 6,
        'MatchDecisions::Four::ConfirmMatchSuccessDndStaff' => 7,
      )
    end
  end

  describe '.match_steps_for_reporting' do
    it 'places each new confirm-decline step immediately after its originating mainline step' do
      steps = described_class.match_steps_for_reporting

      expect(steps['MatchDecisions::Four::ConfirmScheduleCriminalHearingDeclineDndStaff']).to eq(
        steps['MatchDecisions::Four::ScheduleCriminalHearingHousingSubsidyAdmin'] + 1,
      )
      expect(steps['MatchDecisions::Four::ConfirmRecordClientHousedDateDeclineDndStaff']).to eq(
        steps['MatchDecisions::Four::RecordClientHousedDateHousingSubsidyAdministrator'] + 1,
      )
    end

    it 'keeps every step in strictly increasing, gap-free order' do
      values = described_class.match_steps_for_reporting.values
      expect(values).to eq((1..values.size).to_a)
    end
  end
end
