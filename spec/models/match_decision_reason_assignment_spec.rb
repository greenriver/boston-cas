###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchDecisionReasonAssignment, type: :model do
  let(:route) { create(:default_route) }
  let(:other_route) { create(:provider_route) }
  let(:reason_a) { create(:match_decision_reason, name: 'Reason A') }
  let(:reason_b) { create(:match_decision_reason, name: 'Reason B') }

  it 'rejects a kind other than decline or cancel' do
    assignment = build(:match_decision_reason_assignment, route: route, match_decision_reason: reason_a, kind: 'nope')
    expect(assignment).not_to be_valid
  end

  it 'requires a decision_type (there is no route-wide default scope)' do
    assignment = build(:match_decision_reason_assignment, route: route, match_decision_reason: reason_a, decision_type: '')
    expect(assignment).not_to be_valid
  end

  describe 'audience' do
    it 'is valid when blank (visible to everyone)' do
      assignment = build(:match_decision_reason_assignment, route: route, match_decision_reason: reason_a, audience: nil)
      expect(assignment).to be_valid
    end

    it "is valid when set to one of its route's visible contact types, on a step that supports multiple actors" do
      assignment = build(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::ApproveMatchHousingSubsidyAdmin', match_decision_reason: reason_a, audience: 'shelter_agency_contacts')
      expect(assignment).to be_valid
    end

    it 'is invalid when set to a contact type not visible on its route' do
      eight_route = MatchRoutes::Eight.create!(active: true, match_prioritization: create(:priority_days_homeless))
      assignment = build(:match_decision_reason_assignment, route: eight_route, decision_type: 'MatchDecisions::ApproveMatchHousingSubsidyAdmin', match_decision_reason: reason_a, audience: 'shelter_agency_contacts')
      expect(assignment).not_to be_valid
    end

    it 'is invalid when set on a step that does not support multiple actors' do
      assignment = build(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::MatchRecommendationDndStaff', match_decision_reason: reason_a, audience: 'shelter_agency_contacts')
      expect(assignment).not_to be_valid
    end

    it 'is invalid on a cancel-kind assignment, even for a step that supports multiple actors (only decline has a real audience use case today)' do
      assignment = build(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::ApproveMatchHousingSubsidyAdmin', kind: 'cancel', match_decision_reason: reason_a, audience: 'shelter_agency_contacts')
      expect(assignment).not_to be_valid
    end
  end

  describe '.resolve_for' do
    it 'returns step-specific assignments, ordered by position, for that step' do
      create(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline', match_decision_reason: reason_b, position: 1)
      create(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline', match_decision_reason: reason_a, position: 0)

      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline')

      expect(resolved.map(&:match_decision_reason)).to eq([reason_a, reason_b])
    end

    it 'returns an empty list when no assignment exists for that step, with no route-wide fallback' do
      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepWithNoAssignments', kind: 'decline')

      expect(resolved).to eq([])
    end

    it 'does not mix cancel-kind assignments into a decline resolution for the same step' do
      create(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::StepOne', kind: 'cancel', match_decision_reason: reason_a)

      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline')

      expect(resolved).to eq([])
    end

    it 'does not leak another route\'s assignments into resolution' do
      create(:match_decision_reason_assignment, route: other_route, decision_type: 'MatchDecisions::StepOne', kind: 'decline', match_decision_reason: reason_a)

      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline')

      expect(resolved).to eq([])
    end
  end
end
