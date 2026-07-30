###
# Copyright Green River Data Group, Inc.
#
# License detail: https://github.com/greenriver/boston-cas/blob/stable/LICENSE.md
###

# frozen_string_literal: true

require 'rails_helper'

# Throwaway STI subclass exercising only the DB-driven default reason resolution
# (MatchDecisions::Base + MatchDecisions::AcceptsDeclineReason), independent of any
# route-specific concern that might otherwise override step_decline_reasons/step_cancel_reasons.
class MatchDecisions::ReasonResolutionSpecStep < MatchDecisions::Base
  include MatchDecisions::AcceptsDeclineReason
end

RSpec.describe 'MatchDecisions reason resolution', type: :model do
  let(:match) { create(:client_opportunity_match) }
  let(:route) { match.match_route }
  let(:decision) { MatchDecisions::ReasonResolutionSpecStep.create!(match: match) }
  let(:other_reason) { create(:match_decision_reason, name: 'Other') }

  describe '#decline_reasons' do
    it 'resolves options from step-level assignments in position order' do
      reason_b = create(:match_decision_reason, name: 'Reason B')
      reason_a = create(:match_decision_reason, name: 'Reason A')
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: reason_b, position: 1)
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: reason_a, position: 0)

      expect(decision.decline_reasons(contact: nil)).to eq([['Reason A', reason_a.id], ['Reason B', reason_b.id]])
    end

    it 'returns no options when no assignment exists for this step, with no route-wide fallback' do
      expect(decision.decline_reasons(contact: nil)).to eq([])
    end

    it 'excludes inactive reasons' do
      active_reason = create(:match_decision_reason, name: 'Active Reason')
      inactive_reason = create(:match_decision_reason, name: 'Inactive Reason', active: false)
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: active_reason, position: 0)
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: inactive_reason, position: 1)

      expect(decision.decline_reasons(contact: nil)).to eq([['Active Reason', active_reason.id]])
    end

    it 'appends an asterisk to reasons requiring explanation when not all non-Other reasons require it' do
      needs_explanation = create(:match_decision_reason, name: 'Needs Explanation')
      no_explanation = create(:match_decision_reason, name: 'No Explanation Needed')
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: needs_explanation, requires_explanation: true, position: 0)
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: no_explanation, requires_explanation: false, position: 1)

      options = decision.decline_reasons(contact: nil)

      expect(options).to eq([['Needs Explanation*', needs_explanation.id], ['No Explanation Needed', no_explanation.id]])
    end

    it 'omits the asterisk when every non-Other reason requires explanation' do
      needs_explanation = create(:match_decision_reason, name: 'Needs Explanation')
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: needs_explanation, requires_explanation: true, position: 0)
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: other_reason, requires_explanation: false, position: 1)

      options = decision.decline_reasons(contact: nil)

      expect(options).to eq([['Needs Explanation', needs_explanation.id], ['Other', other_reason.id]])
    end
  end

  describe '#cancel_reasons' do
    it 'resolves options from step-level assignments and marks reasons requiring explanation' do
      needs_explanation = create(:match_decision_reason, name: 'Needs Explanation')
      plain = create(:match_decision_reason, name: 'Plain Reason')
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'cancel', match_decision_reason: needs_explanation, requires_explanation: true, position: 0)
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'cancel', match_decision_reason: plain, requires_explanation: false, position: 1)

      expect(decision.cancel_reasons).to eq([['Needs Explanation*', needs_explanation.id], ['Plain Reason', plain.id]])
    end

    it 'returns no options when no cancel assignment exists for this step, with no route-wide fallback' do
      expect(decision.cancel_reasons).to eq([])
    end
  end

  describe '#effective_referral_result' do
    let(:reason) { create(:match_decision_reason, name: 'Some Reason', referral_result: MatchDecisionReasons::Base::CLIENT_REJECTED) }

    it 'returns nil when no decline or cancel reason is set' do
      expect(decision.effective_referral_result).to be_nil
    end

    it "falls back to the reason's own referral_result when no assignment override exists" do
      decision.update!(decline_reason: reason)

      expect(decision.effective_referral_result).to eq(MatchDecisionReasons::Base::CLIENT_REJECTED)
    end

    it "prefers the assignment's referral_result override over the reason's own value" do
      decision.update!(decline_reason: reason)
      create(:match_decision_reason_assignment, route: route, decision_type: decision.class.name, kind: 'decline', match_decision_reason: reason, referral_result: MatchDecisionReasons::Base::PROVIDER_REJECTED)

      expect(decision.effective_referral_result).to eq(MatchDecisionReasons::Base::PROVIDER_REJECTED)
    end

    it 'falls back to the step default when neither the assignment nor the reason set a referral_result' do
      reason_without_default = create(:match_decision_reason, name: 'No Default', referral_result: nil)
      decision.update!(decline_reason: reason_without_default)
      create(:match_decision_step, route: route, decision_type: decision.class.name, default_referral_result: MatchDecisionReasons::Base::PROVIDER_REJECTED)

      expect(decision.effective_referral_result).to eq(MatchDecisionReasons::Base::PROVIDER_REJECTED)
    end
  end
end
