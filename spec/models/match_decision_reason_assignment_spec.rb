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

  describe '.resolve_for' do
    it 'returns step-specific assignments, ordered by position, when they exist for the step' do
      create(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline', match_decision_reason: reason_b, position: 1)
      create(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline', match_decision_reason: reason_a, position: 0)

      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline')

      expect(resolved.map(&:match_decision_reason)).to eq([reason_a, reason_b])
    end

    it 'falls back to the route-level default when no step-specific assignment exists for that step' do
      route_default = create(:match_decision_reason_assignment, route: route, decision_type: '', kind: 'decline', match_decision_reason: reason_a)

      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepWithNoOverride', kind: 'decline')

      expect(resolved).to eq([route_default])
    end

    it 'does not mix cancel-kind assignments into a decline resolution for the same step' do
      create(:match_decision_reason_assignment, route: route, decision_type: 'MatchDecisions::StepOne', kind: 'cancel', match_decision_reason: reason_a)

      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline')

      expect(resolved).to eq([])
    end

    it 'does not leak another route\'s assignments into resolution' do
      create(:match_decision_reason_assignment, route: other_route, decision_type: '', kind: 'decline', match_decision_reason: reason_a)

      resolved = MatchDecisionReasonAssignment.resolve_for(route: route, decision_type: 'MatchDecisions::StepOne', kind: 'decline')

      expect(resolved).to eq([])
    end
  end
end
